import qbs
import Stm32f4Application

Stm32f4Application
{
    property string basePath    : "/home/hans/projects/Software/qt-baremetal/"

    property string outPath     : basePath + "bin/" + qbs.buildVariant + "/"

    property string srcPath     : basePath + "src/"
    property string incPath     : basePath + "src/"
    property string libPath     : basePath + "lib/"

    property string targetFile  : "helloworld_1_0"

    type: ["application", "hex","bin","size", "elf", "disassembly"]
    name: "Hello World!"
    consoleApplication: true

    Group {
        name: "application"
        prefix: srcPath
        files: [
            "*.c"
        ]
    }
}
