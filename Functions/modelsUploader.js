function uploadGlmGamRegression(projectId, models) {
    for (var i = 0; i < models.length; i++) {
        var model = models[i];
        var parameterName = model.parameterName;
        var versionName = model.versionName;
        var regressionType = model.regressionType;
        try {
            earnix.createGlmGamRegressionVersion(projectId, parameterName, versionName, regressionType, { sample: model
                        .sample, dependentColumn: model.dependentColumn, filter: model.filter },
                model.transformations, {});
            //earnix.releaseModelingVersion(projectId, parameterName, versionName);
        } catch (err) {
            println(err.message);
            return 1;
        }
    }
    return 0;
}

function uploadFormula(projectId, models) {
    for (var i = 0; i < models.length; i++) {
        var model = models[i];
        var parameterFolder = model.parameterFolder;
        try {
            earnix.createCustomParametersFolder(projectId, parameterFolder);
        } catch (err) {
            println("Skip: " + err.message);
        }

	   var parameterName = model.parameterName;
	   var parameterType = "Real";
	   var options = {folder: parameterFolder};
	   try {
            earnix.createCustomParameter(projectId, parameterName, parameterType, options);
        } catch (err) {
            println("Skip: " + err.message);
        }

	   var versionName = model.versionName;
	   var formula = model.formula;
        try {
        	  earnix.createFormulaModelingVersion(projectId, parameterName, versionName, formula)
            earnix.releaseModelingVersion(projectId, parameterName, versionName);
        } catch (err) {
            println(err.message);
            return 1;
        }
    }
    return 0;
}

var modelsUploader = {};
var exp = (typeof module !== 'undefined') ? module.exports : modelsUploader;
exp.uploadGlmGamRegression = uploadGlmGamRegression;
exp.uploadFormula = uploadFormula;
