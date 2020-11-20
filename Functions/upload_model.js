// If running externally
earnix.doLoginSSO();

var modelsUploader = require('modelsUploader');

var argsFilePath = cmdArgs[1];
var args = JSON.parse(utils.readFile(argsFilePath));
var projectInfo = JSON.parse(utils.readFile(args.projectInfoFile));
var projectPath = projectInfo.EarnixProjectFolder;
var projectId = earnix.openProject(projectPath);

var modelInfo = JSON.parse(utils.readFile(args.modelInfoFile));
//var modelInfo = utils.readFile(args.modelInfoFile);
println(args.modelInfoFile)
println("Upload models");
try {
    for (var key in modelInfo) {
        var models = modelInfo[key];
        if (models.length == 0) { continue; }

        println("Upload " + key + " models");
        var returnValue = 0;
        if (key == "GlmGamRegression") {
            println('this GlmGamRegression ....')
            returnValue = modelsUploader.uploadGlmGamRegression(projectId, models);
        } else if (key == "ElfFormula") {
            returnValue = modelsUploader.uploadFormula(projectId, models)
        } else if (key == "ElfGlmGam") {
        	  returnValue = modelsUploader.uploadGlmGamRegression(projectId, models);
        }

        if (returnValue == 0) {
            println(key + " models uploaded");
        } else {
            println(key + " models NOT uploaded properly, please check");
        }
    }
} catch (err) {
    println(err.message);
}
