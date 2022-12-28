# Triple Ported Memory
Tripple Ported Memory is a pipelined multi-banked memory module with a dynamic-priority arbitration scheme to resolve bank conflicts. 

The memory module is composed of four banks. Each bank has 1024 words with a word size of 16 bits, giving the module a total capacity of 8KB. The memory is also interleaved such that contiguous memory addresses are shared across each bank in a round-robin manner. 

## Why Multi-banked Memory
Multi-banking is one of the techniques used to increase the number of ports of a memory module. Each port can potentially access different words of the memory simultaneously, thus providing access flexibility without incurring a performance loss when requests don't conflict. 

When different ports request access the same bank (a.k.a. a bank conflict), the requests must arbitrated and perhaps serialized. This module uses a dynamic arcbitration scheme to serialize conflicting accesses.

## How are Bank Conflicts Resolved
Bank conflicts are resolved using a dynamic priority scheme based on the frequency of memory requests from each port. The port that accesses the memory most frequently is served first. For read requests, the top two most frequent ports are served first.

## Top-level Interface
In addition to a clock (`clk`) and an active-low reset (`reset_n`) pin, each port contains the following:
- Input
    - A 12-bit address bus 
    - A 16-bit data bus
    - An active-high write enable pin
    - An active-high valid pin
- Output
    - A 16-bit data bus
    - An active-high valid pin

The reset pin is not used to initialize the memory array, but rather, it is used to initilize the sequential elements and pipeline flip-flops. 

The triple ported memory module can also be halted externally using the `halt` input pin. While halted, the outputs of the memory modules are frozen and so are the internal sequential elements. The `halt` port also gates the clock to the SRAMs and memory bank logic.

The memory module can also request that the elements driving its inputs be frozen using the `freeze_inputs` output pin. 

## Sample Use-Case Waveforms
All simulations were run using [Icarus Verilog](http://iverilog.icarus.com/)

### Coarse-grain Writes then Reads with Consecutive Bank Conflicts
![Waveform showing Coarse-grain Writes then Reads with Bank Conflict](diagrams/waveforms/coarse_write_read_w_bank_conf.png "Course Coarse-Grain Writes then Reads with Bank Conflict")
<div align="center">Simulation Waveform showing coarse-grain writes then reads with bank conflicts on each write and read. Viewed using Gtkwave</div>

The waveform shows that requests can be pipelined. When a bank conlict occurs, the `freeze_inputs` output signal is asserted, prompting the user (perhaps another device) to not change the inputs to the triple ported memory on the next rising edge of the clock. Once the conflicting requests are fulfilled, `freeze_inputs` deasserts, allowing the user the change the inputs to the triple ported memory on the next rising edge of the clock. The waveform also shows the default priority (port1 > port2 > port3) as seen in the staggered outputs on the `port#_data_out` ports. Port 1 and 2's data are returned before port 3's. This priority doesn't change since all ports access the memory with the same frequency.

### Fine-grain Writes then Reads with Consecutive Bank Conflicts

![Waveform showing Fine-grain writes then reads with bank conflicts](diagrams/waveforms/fine_write_read_w_bank_conf.png "Waveform showing Fine-grain writes then reads with bank conflicts")
<div align="center">Simulation Waveform showing fine-grain writes then reads with bank conflicts on each write and read. Viewed using Gtkwave</div>


### Coarse-grain Writes then Reads with No Bank Conflict
![Waveform showing Coarse-grain writes then reads without bank conflicts](diagrams/waveforms/coarse_write_read_wo_bank_conf.png "Waveform showing Coarse-grain writes then reads without bank conflicts")
<div align="center">Simulation Waveform showing coarse-grain writes then reads without bank conflicts. Viewed using Gtkwave</div>

Since no bank conflicts occur, all requests are handled simultaneously, leading to a lower overall latency.

### Fine-grain writes then reads with No Bank Conflict
![Waveform showing Fine-grain writes then reads without bank conflicts](diagrams/waveforms/fine_write_read_wo_bank_conf.png "Waveform showing Fine-grain writes then reads without bank conflicts")
<div align="center">Simulation Waveform showing fine-grain writes then reads without bank conflicts. Viewed using Gtkwave</div>

### Demonstration of Dynamic Priority Arbitration
![Waveform showing dynamic priority arbitration.](diagrams/waveforms/dynamic_port_priority_demo.png "Waveform showing dynamic priority arbitration.")
<div align="center">Waveform showing dynamic priority arbitration. Viewed using Gtkwave.</div>

The waveform above shows that as the access fequency of each port changes (by controlling when `port#_valid_in` is asserted) so does the priority of with which each port's request is handled. The waveform cycles through all six possible priority scenarios: (123->312->321->231->213->132). It appears that there are only three unique scenarios since the memory module is can execute two reads simultaneous even when the requests cause a bank conflict. 

## Architecture
Overview of the modules architecture. Please bear in mind that numerous singals for the sake of simplicity.
### Top-level
![Top-level architecture of the Triple Ported Memory](diagrams/tripple_ported_memory_arch.png)

<div align="center">Top-level architecture of the Triple Ported Memory</div>

Dashed line represents `valid` signals while other signals a represented using the solid arrow.

### Memory Bank Cluster
![Simplified Memory Bank Cluster Architecture](diagrams/memory_bank_cluster_arch.png)
<div align="center">Memory Bank Cluster architecture with SRAMs not shown</div>

## OpenLane Physical Implementation
The physical design for this memory modules was performed using [OpenLane](https://github.com/The-OpenROAD-Project/OpenLane) RTL-to-GDSII flow on SKY130 PDK. A hierarchical design methodology was employed with two macros:

- Memory Bank Logic (hardened)
- SKY130 SRAM macro (sky130_sram_1kbyte_1rw1r_8x1024_8)

Due to computing resource constraints, the DRC stages of the OpenLane flow could not be executed. There are also a some issues regarding the extracted timing models for the hardened macros.

### **Final Design Metrics**:
- **Die Area**: 4.998 mm<sup>2</sup>
- **Core Area**: 4.9166 mm<sup>2</sup>
- **Frequency**: 25 MHz
- **Core Utilization**: 43%

Please note that rigorous design exploration has NOT been conducted.

### **Floorplan**:
![](diagrams/physical_design/floor_plan_tight_design.png "Floor Plan showing sram macros and hardened memory bank logic")
<div align="center">Floorplan showing sram macros and memory bank logic macros. Viewed using OpenROAD gui</div>
The eight larger blocks are the SKY130 sram macros. Two SRAM macros are are needed to provide a 16-bit word size for each bank. The four smaller blocks are the hardnend memory bank logic macros.
<br> 
<br>

### **Routed Design**
![Fully Routed Design in OpenROAD Gui](diagrams/physical_design/routed_design_openroad.png "Fully Routed Design in OpenROAD Gui")
<div align="center">Fully Routed Design in OpenROAD Gui</div>

### **Final GDS** 
![Final GDS rendered in Klayout with some layers hidden](diagrams/physical_design/final_gds_klayout.png "Final GDS rendered in Klayout with some layers hidden")
<div align="center">Final GDS rendered in Klayout</div>

## OpenLane Learnings
After spending many hours fighting with the OpenLane RTL-to-GDS flow, I thought it best to share my findings and workarounds. These lessons were written as future notes for myself and as such they may not apply to your specific scenario or requirements.

### 1. Pre-elaborating Integrated Core RTL
**Motivation:** The OpenLane doesn't handle brackets ( "[" , "]") in the "FP_PDN_MACRO_HOOKS" configuration variable correctly. Whenever brackets are present, the macros aren't connected to the power grid. Brackets are used to identify blocks created using generate statements or instance arrays. Pre-elaborating the integrated core will allow us to change the brackets to something that won't break "FP_PDN_MACRO_HOOKS". Underscores can be used. I have verified that this workaround works.  

**Steps:**

- After finalizing the design, it is assumed you have the following directories in your work area: 

    - `src/`

        - Contains verilog source files and header files. May contain files that will be come macros. 

    - `import/`

        - Contains verilog files for macros used in simulation (eg: sky130 sram macros) 

    - `sim/` 
        - Containing testbenches and files needed for simulation only. 

- Harden the desired macros 

- After hardening each of the macros, in the ~/OpenLane/designs/<design>/ directory for the final chip/core, create and populate the following directories 

    - `import/`

        - In this directory, place black box verilog files for each of the hardened macros. 

    - `src/` 

        - In this directory, place non-macro verilog files and associated header files 

- Using yosys, elaborate the design using the files in the OpenLane "import" and "src" directories you just created (see above),  

    - ```read_verilog -Isrc/ src/*.v import/*.v ```

    - ```hierarchy –top <top_module>```

    - ```write_verilog -noattr <elab>.v```

 
- You can make formatting changes to the <elab>.v file to make the openlane flow work correctly. 

    -  For example you can remover brackets ("[" , "]") from <elab>.v which ensures that "FP_PDN_MACRO_HOOKS" works correctly. The brackets can be changed to underscores. 

- Change the instance names of modules in the file referenced by "MACRO_PLACEMENT_CFG". The instance names in the file needs to match the instance names in the netlist synthesized by openlane. 

- In the config.json file for the OpenLane project, use  <elab>.v as the verilog source (specified by the "VERILOG_FILES" key), Follow the usual chip integration for the remaining steps in the flow ([Openlane Tutorials](https://openlane.readthedocs.io/en/latest/tutorials/openram.html))

### 2. LVS Issues with bundled sky130_sram_1kbyte_1rw1r_8x1024_8 SRAM macro
I found that the flow kept breaking due to a some LVS issues with the sky130_sram_1kbyte_1rw1r_8x1024_8 SRAM macro that came with OpenLane. I rebuilt an equiavlent macro using OpenRAM and flow completed sucessfully. 

