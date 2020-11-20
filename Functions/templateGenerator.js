function createCustomParameters(projectId, all){
	var existingParameters = earnix.getProjectParameters(projectId); 
	println(projectId)
	println(all)
	// Delete the existing default parameters created by Earnix
	var parameterNames = ['Core Margin to Actuarial Cost Ratio', 
	                      'Core Premium Increase', 'Relative Core Premium Increase']; 
	for (var i = 0; i < parameterNames.length; i++) {
		if (existingParameters.indexOf(parameterNames[i]) > -1) {
			earnix.deleteParameter(projectId, parameterNames[i]); 	
		}                     
	}

	// Having to create a dummy realse version for demand core parameters first; Otherwise the Earnix would
	// report an error when we try to create and relase some Review custom parameters 
	var versionName = 'Default version';
	parameterNames = ['Origination Demand', 'Renewal Demand'];
	for (var i = 0; i < parameterNames.length; i++) {	
		var existingVersions = earnix.getParameterVersions(projectId, parameterNames[i]); 
		if (existingVersions.indexOf(versionName) > -1) {
			continue; 
		}	
		earnix.createFormulaModelingVersion(projectId, parameterNames[i], versionName, "1");
		earnix.releaseModelingVersion(projectId, parameterNames[i], versionName);
	}

	var existingFolders = earnix.getCustomParametersFolders(projectId); 
	var parameters = all.CustomParameters; 
	// Create parameters
	for (folderName in parameters) {
		if (existingFolders.indexOf("\\"+folderName) < 0) {
			earnix.createCustomParametersFolder(projectId, folderName);
		}
		
		parametersInFolder = parameters[folderName];
		for (var i = 0; i < parametersInFolder.length; i++) {
			var parameter = parametersInFolder[i]; 
			var parameterName = parameter.Parameter.trim();
		
			if (existingParameters.indexOf(parameterName) < 0) {
				if (parameter.ParameterComment != 'NA') {
					earnix.createCustomParameter(projectId, parameterName, parameter.DataType, 
						{folder: parameter.Folder, comment: parameter.ParameterComment});
				} else {
					earnix.createCustomParameter(projectId, parameterName, parameter.DataType, 
						{folder: parameter.Folder});
				}
				
			}

			existingVersions = earnix.getParameterVersions(projectId, parameterName); 	
			// Note: have to use '0' as placeholder; Otherwise, the order to create the paramter is essential
			var versionName = 'Default version'; 
			if (parameter.Version != 'NA') {
				versionName = parameter.Version; 
			}
			if (existingVersions.indexOf(versionName) > -1) {
				continue; 
			}
			
			if (parameter.DataType == 'Nominal') {
				earnix.createFormulaModelingVersion(projectId, parameterName, versionName, "\"N\"");
			} else {
				earnix.createFormulaModelingVersion(projectId, parameterName, versionName, "0");
			}
			
			earnix.releaseModelingVersion(projectId, parameterName, versionName);				
		}
	}

	// Create modelling version
	for (folderName in parameters) {
		parametersInFolder = parameters[folderName];
		for (var i = 0; i < parametersInFolder.length; i++) {
			var parameter = parametersInFolder[i]; 
			var parameterName = parameter.Parameter.trim();
			var versionName = 'Default version'; 
			if (parameter.Version != 'NA') {
				versionName = parameter.Version; 
			}			
			if (parameter.Formula != "0") {
//				earnix.deleteModelingVersion(projectId, parameterName, versionName);
				earnix.createFormulaModelingVersion(projectId, parameterName, versionName, parameter.Formula);
				earnix.releaseModelingVersion(projectId, parameterName, versionName);
			}
		}
	}
}

function createPricingBehavior(projectId, parameters) {
	// Need to create a dummy variable
	var parameter = parameters.DummyForBehavior
	if (parameter.Formula == '') {
		return; 
	}
	var parameterName = parameter.Parameter.trim();
	var versionName = 'Default version'; 
	earnix.createCustomParameter(projectId, parameterName, parameter.DataType); 
	earnix.createFormulaModelingVersion(projectId, parameterName, versionName, parameter.Formula);
	// Now we can delete the dummy parameter
	earnix.deleteParameter(projectId, parameterName); 

	// We need to update the default behavior
	var parameters = parameters.BehaviorParameters; 
	for (var i = 0; i < parameters.length; i++) {
		var parameter = parameters[i]; 
		if (parameter.Formula == "0") { 
			continue; 
		}
		var parameterName = parameter.Parameter.trim();
		var versionName = 'Default behavior'; 
		earnix.deleteModelingVersion(projectId, parameterName, versionName); 
		earnix.createFormulaModelingVersion(projectId, parameterName, versionName, parameter.Formula);
		earnix.releaseModelingVersion(projectId, parameterName, versionName);
	}	
}

function createAlternativeModelingVersion(projectId, parameters) {
	var parameters = parameters.AlternativeVersions;
	for (ver in parameters) {
		ver_parameters = parameters[ver];
		for (var i = 0; i < ver_parameters.length; i++) {
			var parameter = ver_parameters[i];
			var parameterName = parameter.Parameter.trim();
			var versionName = parameter.Version; 
			earnix.createFormulaModelingVersion(projectId, parameterName, versionName, parameter.Formula);
		}	
	}
}

function createCoreParameterModelingVersion(projectId, parameters) {
	var parameters = parameters.CoreParameters;
	for (var i = 0; i < parameters.length; i++) {
		var parameter = parameters[i]; 
		if (parameter.Formula == "0") { 
			continue; 
		}
		var parameterName = parameter.Parameter.trim();
		var existingVersionNames = earnix.getParameterVersions(projectId, parameterName); 
		for (var j = 0; j < existingVersionNames.length; j++) {
			var existingName = existingVersionNames[j]; 
			earnix.deleteModelingVersion(projectId, parameterName, existingName); 
		}	
		var versionName = 'Default version';
		earnix.createFormulaModelingVersion(projectId, parameterName, versionName, parameter.Formula);	
		earnix.releaseModelingVersion(projectId, parameterName, versionName);
	}
}

function createDataTableFolders(projectId) {
	var existingFolders = earnix.getDataTablesFolders(projectId);	
	// Delete the existing default folder
	var folderName = "Data Tables"; 
	if (existingFolders.indexOf(folderName) > -1) {
		try {
			earnix.deleteDataTablesFolder(projectId, folderName); 
		} catch (err) {
			println(err.message)
		}
	}
	
	// Add new folders
	var folderNames = ["1. NBS", "2. RNW", "3. MTC/MTA", "4. Optimisation", 
				    "5. Monitoring", "Mapping Tables"];
	for (var i = 0; i < folderNames.length; i++) {
		if (existingFolders.indexOf(folderNames[i]) > -1) {
    	     	continue; 
    	   	}
		try {
			earnix.createDataTablesFolder(projectId, folderNames[i]);
		}
		catch (err) {
			println(err.message)
		}
	}
}

function updateParameterModelingVersion(projectId, parameters) {
	for (var i = 0; i < parameters.length; i++) {
		var parameter = parameters[i];
		var parameterName = parameter.Parameter.trim();
		// Update the Default version
		var versionName = 'Default version';
		earnix.deleteModelingVersion(projectId, parameterName, versionName);
		earnix.createFormulaModelingVersion(projectId, parameterName, versionName, parameter.Formula);	
		earnix.releaseModelingVersion(projectId, parameterName, versionName);
		
	}
}

// Create the pricing project template 
function createTemplate(projectId, parameters) {
	// Create the data table folders
	createDataTableFolders(projectId); 

	// Models and modeling version
	createCustomParameters(projectId, parameters);

	// Core parameter modeling version
	createCoreParameterModelingVersion(projectId, parameters); 

	// Pricing behavior
	createPricingBehavior(projectId, parameters); 
 
	// Create alternative modeling version
	createAlternativeModelingVersion(projectId, parameters);  
}

var templateGenerator = {};
var exp = (typeof module !== 'undefined') ? module.exports : templateGenerator;
exp.createTemplate = createTemplate; 
exp.updateParameterModelingVersion = updateParameterModelingVersion; 
