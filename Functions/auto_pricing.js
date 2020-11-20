// If running externally 
earnix.doLoginSSO();

var templateGenerator = require('templateGenerator')
// var dataUploader = require('dataUploader')
// var modelsUploader = require('modelsUploader')
// var pricingGenerator = require('pricingGenerator')

var argsFilePath = cmdArgs[1];
// var argsFilePath = args.argsFilePath;
var args = JSON.parse(utils.readFile(argsFilePath));
var projectInfo = JSON.parse(utils.readFile(args.projectInfoFile));
// Define the project 
var product = projectInfo.Product;
var transaction = projectInfo.Transaction;
var projectFolder = projectInfo.EarnixFolder;
var projectName = projectInfo.EarnixProjectName; 
var makeTemplate = projectInfo.MakeTemplate; 
var uploadData = projectInfo.UploadData;
var uploadModels = projectInfo.UploadModels
var createPricingVersion = projectInfo.CreatePricingVersion

var projectPath = projectInfo.EarnixProjectFolder;
// Create the new pricing project if it does not exist, otherwise using the existing project
try {
	projectPath = earnix.createPricingProject(projectName, projectFolder, {optType: "MARGIN"}); 
}
catch (err) {
	println(err.message); 
	println("The pricing project already existed, using the pricing project existed"); 
}
var projectId = earnix.openProject(projectPath); 


// Create the project template
if (makeTemplate) {
	println("Create the parameters template")
	try {
		var parametersTemplate = JSON.parse(utils.readFile(args.parametersTemplateFile));
		templateGenerator.createTemplate(projectId, parametersTemplate);
		println("The parameters template created")
	}
	catch (err) {
		println(err.message);
	}
}

/*
// Import the data
if (uploadData) {
	println("Upload data")
	try {
		var dataInfo = JSON.parse(utils.readFile(args.dataInfoFile));
		dataUploader.upload(projectId, dataInfo); 
		println("Data uploaded");
	}
	catch (err) {
		println(err.message);
	}	
}

// Import models
if (uploadModels) {
	println("Upload models")
	try {
		var models= JSON.parse(utils.readFile(args.modelInfoFile));
		modelsUploader.upload(projectId, models); 
		println("Models uploaded")
	}
	catch (err) {
		println(err.message);
	}
}

// Try to update financial assumptions parameters
try {
	println("Update financial assumptions parameters");
	var financials = JSON.parse(utils.readFile(args.financialAssumptionsFile));
	templateGenerator.updateParameterModelingVersion(projectId, financials); 
	println("Financial assumptions updated");
}
catch (err) {	
	println(err.message);
}

if (createPricingVersion) {
	println("Create pricing versions");
	try {
		var pricingVersions = JSON.parse(utils.readFile(args.pricingInfoFile))
		pricingGenerator.createVersions(projectId, pricingVersions); 
		println("Pricing version created"); 
	}
	catch (err) {
		println(err.message);
	}
}
*/
println("All done!")
