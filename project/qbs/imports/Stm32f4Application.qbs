import qbs
import qbs.FileInfo
import qbs.File
import "FileExtension.js" as FileExtension

Product {
    property string convertPath : outPath
    Depends { name: "cpp" }
    name: "ARM STM32F4xx GCC"

    targetName: targetFile
    cpp.warningLevel: 'all'
    cpp.positionIndependentCode: false

    cpp.includePaths: [
        incPath,

        libPath + "STM32F4xx/STM32F4xx_StdPeriph_Driver/inc/",
        libPath + "STM32F4xx/Include/",
        libPath + "STM32F4xx/",
    ]

    Properties {
        condition: qbs.buildVariant === "debug"

        cpp.commonCompilerFlags: [
            "-mcpu=cortex-m4",
            "-mthumb",
            "-mfloat-abi=hard",
            "-mfpu=fpv4-sp-d16",
            //"-O0",
            "-g",
            "-DSTM32F40_41xxx",
            "-std=gnu99",
            //"-flto", // standard link-time optimizer
            "-ffunction-sections",
            "-fdata-sections",
            "-Wno-missing-braces"
        ]
        cpp.debugInformation: true
        cpp.optimization: "none"
    }

    Properties {
        condition: qbs.buildVariant === "release"

        cpp.commonCompilerFlags: [
            "-mcpu=cortex-m4",
            "-mthumb",
            "-mfloat-abi=hard",
            "-mfpu=fpv4-sp-d16",
            "-DNDEBUG",
            "-DSTM32F40_41xxx",
            "-O3",
            "-std=gnu99",
            "-flto",
            "-ffunction-sections",
            "-fdata-sections",
        ]
        cpp.debugInformation: false
        cpp.optimization: "small"
    }

    cpp.linkerFlags: [
        "-T"+libPath+"STM32F4xx/stm32f407_std.ld",
        "-mcpu=cortex-m4",
        "-mfloat-abi=hard",
        "-mfpu=fpv4-sp-d16",
        "-mthumb",
        "-Wl,-Map," + outPath + targetFile + ".map",
        "-ffunction-sections",
        "-fdata-sections",
        "-Wl,--gc-sections",
        //"--specs=nano.specs",
        //"--specs=nosys.specs"
    ]

    Group {
        name: "CMSIS-StdPeriph"
        prefix: libPath + "STM32F4xx/STM32F4xx_StdPeriph_Driver/src/"
        files: [
            "*.c"
        ]
        excludeFiles: [
            "stm32f4xx_fmc.c"
        ]
    }
    Group {
        name: "CMSIS-Startup"
        prefix: libPath + "STM32F4xx/"
        files: [
            "*.c",
            "Startup/startup_stm32f40xx.s"
        ]
    }




    Rule {
        id: hex
        inputs: "application"
        Artifact {
            fileTags: "hex"
            filePath: "../../" + FileExtension.FileExtension(input.filePath, 1) + "/" + FileInfo.baseName(input.filePath) + ".hex"
        }
        prepare: {
            var args = ["-O", "ihex", input.filePath, output.filePath];
            var cmd = new Command("arm-none-eabi-objcopy", args);
            cmd.description = "converting to hex: "+FileInfo.fileName(input.filePath);
            cmd.highlight = "linker";
            return cmd;
        }
    }

    Rule {
        id: elf
        inputs: "application"
        Artifact {
            fileTags: "elf"
            filePath: "../../" + FileExtension.FileExtension(input.filePath, 1) + "/" + FileInfo.baseName(input.filePath) + ".elf"
        }
        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.sourceCode = function() {
                File.copy(input.filePath, output.filePath)
            };
            cmd.description = "copying elf: " + FileInfo.fileName(input.filePath);
            cmd.highlight = "linker";
            return cmd;
        }
    }

    Rule {
        id: bin
        inputs: "application"
        Artifact {
            fileTags: "bin"
            filePath: "../../" + FileExtension.FileExtension(input.filePath, 1) + "/" + FileInfo.baseName(input.filePath) + ".bin"
        }
        prepare: {
            var args = ["-O", "binary", input.filePath, output.filePath];
            var cmd = new Command("arm-none-eabi-objcopy", args);
            cmd.description = "converting to bin: "+FileInfo.fileName(input.filePath);
            cmd.highlight = "linker";
            return cmd;

        }
    }

    Rule {
        id: size
        inputs: "application"
        Artifact {
            fileTags: "size"
            filePath: "-"
        }
        prepare: {
            var args = [input.filePath];
            var cmd = new Command("arm-none-eabi-size", args);
            cmd.description = "File size: " + FileInfo.fileName(input.filePath);
            cmd.highlight = "linker";
            return cmd;
        }
    }

    Rule {
        id: disassmbly
        inputs: "application"
        Artifact {
            fileTags: "disassembly"
            filePath: "../../" + FileExtension.FileExtension(input.filePath, 1) + "/" + FileInfo.baseName(input.filePath) + ".lst"
        }
        prepare: {
            var cmd = new Command("arm-none-eabi-objdump", [input.filePath, '-D','-S']);
            cmd.stdoutFilePath = output.filePath;
            cmd.description = "Disassembly listing for " + cmd.workingDirectory;
            cmd.highlight = "disassembler";
            cmd.silent = true;

            return cmd;
        }
    }
}
