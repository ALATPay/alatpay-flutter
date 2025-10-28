allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.layout.buildDirectory.set(file("../build"))

subprojects {
    layout.buildDirectory.set(rootProject.layout.buildDirectory.dir(name))
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}


//allprojects {
//    repositories {
//        google()
//        mavenCentral()
//    }
//}
//
//val newBuildDir: Directory =
//    rootProject.layout.buildDirectory
//        .dir("../../build")
//        .get()
//rootProject.layout.buildDirectory.value(newBuildDir)
//
////subprojects {
////    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
////    project.layout.buildDirectory.value(newSubprojectBuildDir)
////    afterEvaluate { subproject ->
////        if (subproject.name.contains("webview_flutter_android")) {
////            subproject.extensions.findByName("android")?.namespace = "io.flutter.plugins.webviewflutter"
////        }
////    }
////}
//subprojects {
//    project.evaluationDependsOn(":app")
//}
//
//tasks.register<Delete>("clean") {
//    delete(rootProject.layout.buildDirectory)
//}
//
//
