// If running externally
//println('These are messages regarding the Earnix login ... similar warnings must be \n read from the CMD screen when one manually opens Earnix')


earnix.doLoginSSO();
//
//println('please make some reations ')
//System.out.printf(earnix)
//System.out.printf(earnix)
//System.out.printf(earnix)
//println('please make some reations ')

var argsFilePath = cmdArgs[1];
var args = JSON.parse(utils.readFile(argsFilePath));
var projectInfo = JSON.parse(utils.readFile(args.projectInfoFile));
var projectPath = projectInfo.EarnixProjectFolder;
var projectId = earnix.openProject(projectPath);
println('we ARE  also here')
println(argsFilePath)
println(args)
println('we ARE  also here')

println("Upload data tables");
try {
    var dataTables = JSON.parse(utils.readFile(args.dataInfoFile));
    for (var i = 0; i < dataTables.length; i++) {
        var table = dataTables[i];
        var tableName = table.earnixTableName;
        var csvFileName = table.dataTableFile;
        var map = table.map;
        var types = table.types;
        var datePattern = table.datePattern;
        println("Upload data file " + csvFileName + " as table " + tableName);
        earnix.importDataTableFromCSVFile(projectId, tableName, csvFileName,
            {types: types, datePatternCountry: 'UK', datePattern: datePattern});
        println("Mapping variables for table " + tableName);
        earnix.mapColumnsToVariables(projectId, tableName, map);
    }
    println("Data tables uploaded");
} catch (err) {
    println(err.message);
    println("Data tables NOT uploaded properly, please check");
}
//yyyy-MM-dd
//dd/MM/yyyy

// var dataInfoFile =
//     "C:/Users/hge/MyWork/Projects/APTest/2020-01 CS PC ALL RNW COS/Auto/Optimization/EarnixDataInfo.json";
// var dataTables = JSON.parse(utils.readFile(dataInfoFile));
// println(JSON.stringify(dataTables, null, 2));
//
// var projectPath = "\\Budget Group\\2019\\All\\Development\\Test\\2020-01 CS PC RNW ALL - COS copy";
// var projectId = earnix.openProject(projectPath);
//
// for (var i = 0; i < dataTables.length; i++) {
//     var table = dataTables[i];
//     var tableName = table.earnixTableName;
//     var csvFileName = table.dataTableFile;
//     var map = table.map
//     var types = table.types
//     try {
// 	   earnix.importDataTableFromCSVFile(projectId, tableName, csvFileName,
// 	   		{types: types, datePatternCountry: 'UK', datePattern: 'dd/MM/yyyy' })
// 	   earnix.mapColumnsToVariables(projectId, tableName, map)
//     } catch (err) {
//         println(err.message);
//     }
// }


// var projectPath = "\\Budget Group\\2016\\All\\NBS\\Frontline\\Budget\\Van\\2018-10 BIS LC AGG NBS LG copy";
// var projectId = earnix.openProject(projectPath);
//
// var mapTableName = "Mapping Tables\\Variable Mapping0"
// var mapTable = earnix.getDataTableValues(projectId, mapTableName);
//
// var variableName;
// var earnixMapping;
// for (var i = 0; i < map.length; i++) {
//     if (map[i].name == "VariableName") {
//         variableName = map[i].values;
//     }
//     if (map[i].name == "EarnixMapping") {
//         earnixMapping = map[i].values;
//     }
// }

//println(JSON.stringify(variableName, null, 2))
//println(JSON.stringify(earnixMapping, null, 2))

// var tableName = "\\3. MTC/MTA\\Test"
// var csvFileName = "P:/Stats & R&D/Modelling/2018-10 BIS LC AGG NBS LG/3. Data/MTCData_BIS_LC_NBS_AGG.csv"
//earnix.importDataTableFromCSVFile(projectId, tableName, csvFileName, { datePatternCountry: 'UK',
//    datePattern: 'yyyy-MM-dd' })

//map = [['CC_AplsummaryAlias_no_UPB', 'CCR_UPB'], ['CC_AddrlinkAddmain_WGB', 'CCR_WGB']]
//earnix.mapColumnsToVariables(projectId, tableName, map)

// var dict = {
//     FirstName: "Chris",
//     "one": 1,
//     1: "some value"
// };
//
// var key = "one";
// println(dict[key]);