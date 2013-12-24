
// revised 11.19.2013 by Matthew Shaxted

var arguments = process.argv.splice(2);

var outputFilename = arguments[0];
outputFilename = outputFilename.replace(".xml",".json");
//outputFilename = outputFilename.split("output")[1];
//outputFilename = outputFilename[1];
//console.log(outputFilename);

var fs = require('fs');
var parser = require('xml2json');

// write file
var writefile = true;
//var outputFilename = __dirname+'/output.json';

// deposit to mongoDB
var dbresult = false;

var dbinput = arguments[1];

var dbaddress = 'mongodb://'+
'genius'+
'mongodb123'+"@"+
'urbangeni.us'+
':27017'+
'/EP';

var dbcollection = 'PILOTRUN1';

fs.readFile('eplustbl.xml', function(err, data) {
//fs.readFile('SWEEP_RECTTable.xml', function(err, data) {


var options = {
    object: true,
    reversible: false,
    coerce: true,
    sanitize: true,
    trim: true,
    arrayNotation: false
};

var json = parser.toJson(data,options); //returns a string containing the JSON structure by default

var ModelArea = parseFloat(json.EnergyPlusTabularReports.AnnualBuildingUtilityPerformanceSummary.BuildingArea.TotalBuildingArea);

var RawMonthlyElectricity = (json.EnergyPlusTabularReports.Enduseenergyconsumptionelectricitymonthly.EnduseenergyconsumptionelectricitymonthlyRecord);
var RawMonthlyGas = (json.EnergyPlusTabularReports.Enduseenergyconsumptionnaturalgasmonthly.EnduseenergyconsumptionnaturalgasmonthlyRecord);

//console.log(RawMonthlyElectricity);
//console.log(RawMonthlyGas);

//cooling
for (i=0;i<RawMonthlyElectricity.length;i++){
    var RawCoolingElectricity=[];
    //console.log(RawMonthlyElectricity[i].name.$t);
if (RawMonthlyElectricity[i].name.$t=='CoolingElectricity') {
     //   console.log(RawMonthlyElectricity[i].name.$t);
       RawCoolingElectricity = RawMonthlyElectricity[i];
       
       var CoolingMonthly = {
                "January":  Math.round(RawCoolingElectricity.January*0.0000002777778/ModelArea*10000)/10000,
                "February": Math.round(RawCoolingElectricity.February*0.0000002777778/ModelArea*10000)/10000,
                "March": Math.round(RawCoolingElectricity.March*0.0000002777778/ModelArea*10000)/10000,
                "April": Math.round(RawCoolingElectricity.April*0.0000002777778/ModelArea*10000)/10000,
                "May": Math.round(RawCoolingElectricity.May*0.0000002777778/ModelArea*10000)/10000,
                "June": Math.round(RawCoolingElectricity.June*0.0000002777778/ModelArea*10000)/10000,
                "July": Math.round(RawCoolingElectricity.July*0.0000002777778/ModelArea*10000)/10000,
                "August": Math.round(RawCoolingElectricity.August*0.0000002777778/ModelArea*10000)/10000,
                "September": Math.round(RawCoolingElectricity.September*0.0000002777778/ModelArea*10000)/10000,
                "October": Math.round(RawCoolingElectricity.October*0.0000002777778/ModelArea*10000)/10000,
                "November": Math.round(RawCoolingElectricity.November*0.0000002777778/ModelArea*10000)/10000,
                "December": Math.round(RawCoolingElectricity.December*0.0000002777778/ModelArea*10000)/10000,
}
//console.log(CoolingMonthly);
   }

// plug/light
    //InteriorlightsElectricity
    //ExteriorlightsElectricity
    //InteriorequipmentElectricity
    //ExteriorequipmentElectricity

var RawIntLights=[];
if (RawMonthlyElectricity[i].name.$t=='InteriorlightsElectricity') {
    //    console.log(RawMonthlyElectricity[i].name.$t);
       RawIntLights = RawMonthlyElectricity[i];
       var IntLightsMonthly = {
                "January":  Math.round(RawIntLights.January*0.0000002777778/ModelArea*10000)/10000,
                "February": Math.round(RawIntLights.February*0.0000002777778/ModelArea*10000)/10000,
                "March": Math.round(RawIntLights.March*0.0000002777778/ModelArea*10000)/10000,
                "April": Math.round(RawIntLights.April*0.0000002777778/ModelArea*10000)/10000,
                "May": Math.round(RawIntLights.May*0.0000002777778/ModelArea*10000)/10000,
                "June": Math.round(RawIntLights.June*0.0000002777778/ModelArea*10000)/10000,
                "July": Math.round(RawIntLights.July*0.0000002777778/ModelArea*10000)/10000,
                "August": Math.round(RawIntLights.August*0.0000002777778/ModelArea*10000)/10000,
                "September": Math.round(RawIntLights.September*0.0000002777778/ModelArea*10000)/10000,
                "October": Math.round(RawIntLights.October*0.0000002777778/ModelArea*10000)/10000,
                "November": Math.round(RawIntLights.November*0.0000002777778/ModelArea*10000)/10000,
                "December": Math.round(RawIntLights.December*0.0000002777778/ModelArea*10000)/10000,
}
//console.log(IntLightsMonthly);
   }
   
   var RawExtLights=[];
if (RawMonthlyElectricity[i].name.$t=='ExteriorlightsElectricity') {
    //    console.log(RawMonthlyElectricity[i].name.$t);
       RawExtLights = RawMonthlyElectricity[i];
       var ExtLightsMonthly = {
                "January":  Math.round(RawExtLights.January*0.0000002777778/ModelArea*10000)/10000,
                "February": Math.round(RawExtLights.February*0.0000002777778/ModelArea*10000)/10000,
                "March": Math.round(RawExtLights.March*0.0000002777778/ModelArea*10000)/10000,
                "April": Math.round(RawExtLights.April*0.0000002777778/ModelArea*10000)/10000,
                "May": Math.round(RawExtLights.May*0.0000002777778/ModelArea*10000)/10000,
                "June": Math.round(RawExtLights.June*0.0000002777778/ModelArea*10000)/10000,
                "July": Math.round(RawExtLights.July*0.0000002777778/ModelArea*10000)/10000,
                "August": Math.round(RawExtLights.August*0.0000002777778/ModelArea*10000)/10000,
                "September": Math.round(RawExtLights.September*0.0000002777778/ModelArea*10000)/10000,
                "October": Math.round(RawExtLights.October*0.0000002777778/ModelArea*10000)/10000,
                "November": Math.round(RawExtLights.November*0.0000002777778/ModelArea*10000)/10000,
                "December": Math.round(RawExtLights.December*0.0000002777778/ModelArea*10000)/10000,
}
//console.log(ExtLightsMonthly);
   }
  
   var RawIntEquip=[];
if (RawMonthlyElectricity[i].name.$t=='InteriorequipmentElectricity') {
    //    console.log(RawMonthlyElectricity[i].name.$t);
       RawIntEquip = RawMonthlyElectricity[i];
       var IntEquipMonthly = {
                "January":  Math.round(RawIntEquip.January*0.0000002777778/ModelArea*10000)/10000,
                "February": Math.round(RawIntEquip.February*0.0000002777778/ModelArea*10000)/10000,
                "March": Math.round(RawIntEquip.March*0.0000002777778/ModelArea*10000)/10000,
                "April": Math.round(RawIntEquip.April*0.0000002777778/ModelArea*10000)/10000,
                "May": Math.round(RawIntEquip.May*0.0000002777778/ModelArea*10000)/10000,
                "June": Math.round(RawIntEquip.June*0.0000002777778/ModelArea*10000)/10000,
                "July": Math.round(RawIntEquip.July*0.0000002777778/ModelArea*10000)/10000,
                "August": Math.round(RawIntEquip.August*0.0000002777778/ModelArea*10000)/10000,
                "September": Math.round(RawIntEquip.September*0.0000002777778/ModelArea*10000)/10000,
                "October": Math.round(RawIntEquip.October*0.0000002777778/ModelArea*10000)/10000,
                "November": Math.round(RawIntEquip.November*0.0000002777778/ModelArea*10000)/10000,
                "December": Math.round(RawIntEquip.December*0.0000002777778/ModelArea*10000)/10000,
}
//console.log(IntEquipMonthly);
   }   
   
      var RawExtEquip=[];
if (RawMonthlyElectricity[i].name.$t=='ExteriorequipmentElectricity') {
   // console.log(RawMonthlyElectricity[i].name.$t);
       RawExtEquip = RawMonthlyElectricity[i];
       var ExtEquipMonthly = {
                "January":  Math.round(RawExtEquip.January*0.0000002777778/ModelArea*10000)/10000,
                "February": Math.round(RawExtEquip.February*0.0000002777778/ModelArea*10000)/10000,
                "March": Math.round(RawExtEquip.March*0.0000002777778/ModelArea*10000)/10000,
                "April": Math.round(RawExtEquip.April*0.0000002777778/ModelArea*10000)/10000,
                "May": Math.round(RawExtEquip.May*0.0000002777778/ModelArea*10000)/10000,
                "June": Math.round(RawExtEquip.June*0.0000002777778/ModelArea*10000)/10000,
                "July": Math.round(RawExtEquip.July*0.0000002777778/ModelArea*10000)/10000,
                "August": Math.round(RawExtEquip.August*0.0000002777778/ModelArea*10000)/10000,
                "September": Math.round(RawExtEquip.September*0.0000002777778/ModelArea*10000)/10000,
                "October": Math.round(RawExtEquip.October*0.0000002777778/ModelArea*10000)/10000,
                "November": Math.round(RawExtEquip.November*0.0000002777778/ModelArea*10000)/10000,
                "December": Math.round(RawExtEquip.December*0.0000002777778/ModelArea*10000)/10000,
}
//console.log(ExtEquipMonthly);
   }   
   
  //auxilary 
     //FansElectricity
     //PumpsElectricity
     //HeatrejectionElectricity

      var RawFanElec=[];
if (RawMonthlyElectricity[i].name.$t=='FansElectricity') {
  //  console.log(RawMonthlyElectricity[i].name.$t);
       RawFanElec = RawMonthlyElectricity[i];
       var FanMonthly = {
                "January":  Math.round(RawFanElec.January*0.0000002777778/ModelArea*10000)/10000,
                "February": Math.round(RawFanElec.February*0.0000002777778/ModelArea*10000)/10000,
                "March": Math.round(RawFanElec.March*0.0000002777778/ModelArea*10000)/10000,
                "April": Math.round(RawFanElec.April*0.0000002777778/ModelArea*10000)/10000,
                "May": Math.round(RawFanElec.May*0.0000002777778/ModelArea*10000)/10000,
                "June": Math.round(RawFanElec.June*0.0000002777778/ModelArea*10000)/10000,
                "July": Math.round(RawFanElec.July*0.0000002777778/ModelArea*10000)/10000,
                "August": Math.round(RawFanElec.August*0.0000002777778/ModelArea*10000)/10000,
                "September": Math.round(RawFanElec.September*0.0000002777778/ModelArea*10000)/10000,
                "October": Math.round(RawFanElec.October*0.0000002777778/ModelArea*10000)/10000,
                "November": Math.round(RawFanElec.November*0.0000002777778/ModelArea*10000)/10000,
                "December": Math.round(RawFanElec.December*0.0000002777778/ModelArea*10000)/10000,
}
//console.log(FanMonthly);
   }   
   
      var RawPumpElec=[];
if (RawMonthlyElectricity[i].name.$t=='PumpsElectricity') {
 //   console.log(RawMonthlyElectricity[i].name.$t);
       RawPumpElec = RawMonthlyElectricity[i];
       var PumpMonthly = {
                "January":  Math.round(RawPumpElec.January*0.0000002777778/ModelArea*10000)/10000,
                "February": Math.round(RawPumpElec.February*0.0000002777778/ModelArea*10000)/10000,
                "March": Math.round(RawPumpElec.March*0.0000002777778/ModelArea*10000)/10000,
                "April": Math.round(RawPumpElec.April*0.0000002777778/ModelArea*10000)/10000,
                "May": Math.round(RawPumpElec.May*0.0000002777778/ModelArea*10000)/10000,
                "June": Math.round(RawPumpElec.June*0.0000002777778/ModelArea*10000)/10000,
                "July": Math.round(RawPumpElec.July*0.0000002777778/ModelArea*10000)/10000,
                "August": Math.round(RawPumpElec.August*0.0000002777778/ModelArea*10000)/10000,
                "September": Math.round(RawPumpElec.September*0.0000002777778/ModelArea*10000)/10000,
                "October": Math.round(RawPumpElec.October*0.0000002777778/ModelArea*10000)/10000,
                "November": Math.round(RawPumpElec.November*0.0000002777778/ModelArea*10000)/10000,
                "December": Math.round(RawPumpElec.December*0.0000002777778/ModelArea*10000)/10000,
}
//console.log(PumpMonthly);
   }   
   
         var RawHRElec=[];
if (RawMonthlyElectricity[i].name.$t=='HeatrejectionElectricity') {
  //  console.log(RawMonthlyElectricity[i].name.$t);
       RawHRElec = RawMonthlyElectricity[i];
       var HRMonthly = {
                "January":  Math.round(RawHRElec.January*0.0000002777778/ModelArea*10000)/10000,
                "February": Math.round(RawHRElec.February*0.0000002777778/ModelArea*10000)/10000,
                "March": Math.round(RawHRElec.March*0.0000002777778/ModelArea*10000)/10000,
                "April": Math.round(RawHRElec.April*0.0000002777778/ModelArea*10000)/10000,
                "May": Math.round(RawHRElec.May*0.0000002777778/ModelArea*10000)/10000,
                "June": Math.round(RawHRElec.June*0.0000002777778/ModelArea*10000)/10000,
                "July": Math.round(RawHRElec.July*0.0000002777778/ModelArea*10000)/10000,
                "August": Math.round(RawHRElec.August*0.0000002777778/ModelArea*10000)/10000,
                "September": Math.round(RawHRElec.September*0.0000002777778/ModelArea*10000)/10000,
                "October": Math.round(RawHRElec.October*0.0000002777778/ModelArea*10000)/10000,
                "November": Math.round(RawHRElec.November*0.0000002777778/ModelArea*10000)/10000,
                "December": Math.round(RawHRElec.December*0.0000002777778/ModelArea*10000)/10000,
}
//console.log(HRMonthly);
   }   
   
   
   

}


// heating and dhw
for (i=0;i<RawMonthlyGas.length;i++){
    
    var RawHeatingGas=[];
    //console.log(RawMonthlyElectricity[i].name.$t);
if (RawMonthlyGas[i].name.$t=='HeatingGas') {
    
      //      console.log(RawMonthlyGas[i].name.$t);
       RawHeatingGas = RawMonthlyGas[i];
       
       var HeatingMonthly = {
                "January":  Math.round(RawHeatingGas.January*0.0000002777778/ModelArea*10000)/10000,
                "February": Math.round(RawHeatingGas.February*0.0000002777778/ModelArea*10000)/10000,
                "March": Math.round(RawHeatingGas.March*0.0000002777778/ModelArea*10000)/10000,
                "April": Math.round(RawHeatingGas.April*0.0000002777778/ModelArea*10000)/10000,
                "May": Math.round(RawHeatingGas.May*0.0000002777778/ModelArea*10000)/10000,
                "June": Math.round(RawHeatingGas.June*0.0000002777778/ModelArea*10000)/10000,
                "July": Math.round(RawHeatingGas.July*0.0000002777778/ModelArea*10000)/10000,
                "August": Math.round(RawHeatingGas.August*0.0000002777778/ModelArea*10000)/10000,
                "September": Math.round(RawHeatingGas.September*0.0000002777778/ModelArea*10000)/10000,
                "October": Math.round(RawHeatingGas.October*0.0000002777778/ModelArea*10000)/10000,
                "November": Math.round(RawHeatingGas.November*0.0000002777778/ModelArea*10000)/10000,
                "December": Math.round(RawHeatingGas.December*0.0000002777778/ModelArea*10000)/10000,
}
//console.log(HeatingMonthly);
    
}

/*
    var RawDHWGas=[];
    //console.log(RawMonthlyElectricity[i].name.$t);
if (RawMonthlyGas[i].name.$t=='WatersystemsGas') {
    
//            console.log(RawMonthlyGas[i].name.$t);
       RawDHWGas = RawMonthlyGas[i];
       
       var DHWMonthly = {
                "January":  Math.round(RawDHWGas.January*0.0000002777778/ModelArea*10000)/10000,
                "February": Math.round(RawDHWGas.February*0.0000002777778/ModelArea*10000)/10000,
                "March": Math.round(RawDHWGas.March*0.0000002777778/ModelArea*10000)/10000,
                "April": Math.round(RawDHWGas.April*0.0000002777778/ModelArea*10000)/10000,
                "May": Math.round(RawDHWGas.May*0.0000002777778/ModelArea*10000)/10000,
                "June": Math.round(RawDHWGas.June*0.0000002777778/ModelArea*10000)/10000,
                "July": Math.round(RawDHWGas.July*0.0000002777778/ModelArea*10000)/10000,
                "August": Math.round(RawDHWGas.August*0.0000002777778/ModelArea*10000)/10000,
                "September": Math.round(RawDHWGas.September*0.0000002777778/ModelArea*10000)/10000,
                "October": Math.round(RawDHWGas.October*0.0000002777778/ModelArea*10000)/10000,
                "November": Math.round(RawDHWGas.November*0.0000002777778/ModelArea*10000)/10000,
                "December": Math.round(RawDHWGas.December*0.0000002777778/ModelArea*10000)/10000,
}
//console.log(DHWMonthly);
    
}
*/

}


// compile the results even further

// AuxMonthly = PumpMonthly, FanMonthly, HRMonthly
// PlugLightMonthly = ExtLightsMonthly, IntLightsMonthly, ExtEquipMonthly, IntEquipMonthly

var AuxMonthly = {
                "January":   Math.round((PumpMonthly.January + FanMonthly.January + HRMonthly.January)*10000)/10000,
                "February": Math.round((PumpMonthly.February + FanMonthly.February + HRMonthly.February)*10000)/10000,
                "March": Math.round((PumpMonthly.March + FanMonthly.March + HRMonthly.March)*10000)/10000,
                "April":Math.round(( PumpMonthly.April + FanMonthly.April + HRMonthly.April)*10000)/10000,
                "May": Math.round((PumpMonthly.May + FanMonthly.May + HRMonthly.May)*10000)/10000,
                "June": Math.round((PumpMonthly.June + FanMonthly.June + HRMonthly.June)*10000)/10000,
                "July": Math.round((PumpMonthly.July + FanMonthly.July + HRMonthly.July)*10000)/10000,
                "August": Math.round((PumpMonthly.August + FanMonthly.August + HRMonthly.August)*10000)/10000,
                "September":Math.round(( PumpMonthly.September + FanMonthly.September + HRMonthly.September)*10000)/10000,
                "October": Math.round((PumpMonthly.October + FanMonthly.October + HRMonthly.October)*10000)/10000,
                "November": Math.round((PumpMonthly.November + FanMonthly.November + HRMonthly.November)*10000)/10000,
                "December":Math.round(( PumpMonthly.December + FanMonthly.December + HRMonthly.December)*10000)/10000,
};

//console.log('Auxiliary');
//console.log(AuxMonthly);

var PlugLightMonthly = {
                "January":    Math.round((ExtLightsMonthly.January + IntLightsMonthly.January + IntEquipMonthly.January + ExtEquipMonthly.January)*10000)/10000,
                "February": Math.round(( ExtLightsMonthly.February + IntLightsMonthly.February + IntEquipMonthly.February + ExtEquipMonthly.February)*10000)/10000,
                "March":  Math.round((ExtLightsMonthly.March + IntLightsMonthly.March + IntEquipMonthly.March + ExtEquipMonthly.March)*10000)/10000,
                "April": Math.round(( ExtLightsMonthly.April + IntLightsMonthly.April + IntEquipMonthly.April + ExtEquipMonthly.April)*10000)/10000,
                "May":  Math.round((ExtLightsMonthly.May + IntLightsMonthly.May + IntEquipMonthly.May + ExtEquipMonthly.May)*10000)/10000,
                "June": Math.round(( ExtLightsMonthly.June + IntLightsMonthly.June + IntEquipMonthly.June + ExtEquipMonthly.June)*10000)/10000,
                "July":  Math.round((ExtLightsMonthly.July + IntLightsMonthly.July  + IntEquipMonthly.July+ ExtEquipMonthly.July)*10000)/10000,
                "August":  Math.round((ExtLightsMonthly.August + IntLightsMonthly.August + IntEquipMonthly.August + ExtEquipMonthly.August)*10000)/10000,
                "September":  Math.round((ExtLightsMonthly.September + IntLightsMonthly.September + IntEquipMonthly.September + ExtEquipMonthly.September)*10000)/10000,
                "October":  Math.round((ExtLightsMonthly.October + IntLightsMonthly.October + IntEquipMonthly.October + ExtEquipMonthly.October)*10000)/10000,
                "November": Math.round(( ExtLightsMonthly.November + IntLightsMonthly.November + IntEquipMonthly.November + ExtEquipMonthly.November)*10000)/10000,
                "December": Math.round(( ExtLightsMonthly.December + IntLightsMonthly.December + IntEquipMonthly.December + ExtEquipMonthly.December)*10000)/10000
};

//console.log('PlugLight');
//console.log(PlugLightMonthly);


// generate the annual and total monthly results

//HeatingMonthly, CoolingMonthly, PlugLightMonthly, AuxMonthly, DHWMonthly


var TotalMonthly = {
                "January":    Math.round((HeatingMonthly.January + CoolingMonthly.January + PlugLightMonthly.January + AuxMonthly.January)*10000)/10000,
                "February": Math.round(( HeatingMonthly.February + CoolingMonthly.February + PlugLightMonthly.February + AuxMonthly.February)*10000)/10000,
                "March":  Math.round((HeatingMonthly.March + CoolingMonthly.March + PlugLightMonthly.March + AuxMonthly.March)*10000)/10000,
                "April": Math.round((HeatingMonthly.April + CoolingMonthly.April + PlugLightMonthly.April + AuxMonthly.April)*10000)/10000,
                "May":  Math.round((HeatingMonthly.May + CoolingMonthly.May + PlugLightMonthly.May + AuxMonthly.May)*10000)/10000,
                "June": Math.round((HeatingMonthly.June + CoolingMonthly.June + PlugLightMonthly.June + AuxMonthly.June)*10000)/10000,
                "July":  Math.round((HeatingMonthly.July + CoolingMonthly.July + PlugLightMonthly.July + AuxMonthly.July)*10000)/10000,
                "August":  Math.round((HeatingMonthly.August + CoolingMonthly.August + PlugLightMonthly.August + AuxMonthly.August)*10000)/10000,
                "September":  Math.round((HeatingMonthly.September + CoolingMonthly.September + PlugLightMonthly.September + AuxMonthly.September)*10000)/10000,
                "October":  Math.round((HeatingMonthly.October + CoolingMonthly.October + PlugLightMonthly.October + AuxMonthly.October)*10000)/10000,
                "November": Math.round(( HeatingMonthly.November + CoolingMonthly.November + PlugLightMonthly.November + AuxMonthly.November)*10000)/10000,
                "December": Math.round(( HeatingMonthly.December + CoolingMonthly.December + PlugLightMonthly.December + AuxMonthly.December)*10000)/10000
 
};

var TotalAnnual = Math.round((
TotalMonthly.January +
TotalMonthly.February+
TotalMonthly.March+
TotalMonthly.April+
TotalMonthly.May+
TotalMonthly.June+
TotalMonthly.July+
TotalMonthly.August+
TotalMonthly.September+
TotalMonthly.October+
TotalMonthly.November+
TotalMonthly.December
)*10000)/10000;

var HeatingAnnual = Math.round((
HeatingMonthly.January +
HeatingMonthly.February+
HeatingMonthly.March+
HeatingMonthly.April+
HeatingMonthly.May+
HeatingMonthly.June+
HeatingMonthly.July+
HeatingMonthly.August+
HeatingMonthly.September+
HeatingMonthly.October+
HeatingMonthly.November+
HeatingMonthly.December
)*10000)/10000;

var CoolingAnnual = Math.round((
CoolingMonthly.January +
CoolingMonthly.February+
CoolingMonthly.March+
CoolingMonthly.April+
CoolingMonthly.May+
CoolingMonthly.June+
CoolingMonthly.July+
CoolingMonthly.August+
CoolingMonthly.September+
CoolingMonthly.October+
CoolingMonthly.November+
CoolingMonthly.December
)*10000)/10000;

var PlugLightAnnual = Math.round((
PlugLightMonthly.January +
PlugLightMonthly.February+
PlugLightMonthly.March+
PlugLightMonthly.April+
PlugLightMonthly.May+
PlugLightMonthly.June+
PlugLightMonthly.July+
PlugLightMonthly.August+
PlugLightMonthly.September+
PlugLightMonthly.October+
PlugLightMonthly.November+
PlugLightMonthly.December
)*10000)/10000;

var AuxAnnual = Math.round((
AuxMonthly.January +
AuxMonthly.February+
AuxMonthly.March+
AuxMonthly.April+
AuxMonthly.May+
AuxMonthly.June+
AuxMonthly.July+
AuxMonthly.August+
AuxMonthly.September+
AuxMonthly.October+
AuxMonthly.November+
AuxMonthly.December
)*10000)/10000;

/*
var DHWAnnual = Math.round((
DHWMonthly.January +
DHWMonthly.February+
DHWMonthly.March+
DHWMonthly.April+
DHWMonthly.May+
DHWMonthly.June+
DHWMonthly.July+
DHWMonthly.August+
DHWMonthly.September+
DHWMonthly.October+
DHWMonthly.November+
DHWMonthly.December
)*10000)/10000;
*/

// runID is generated by file name
var direct = (__dirname.split("/"));
var modelID = direct[direct.length-1];
//console.log(modelID);

var units = 'kWh/m2';

// output results

// ModelID - modelID
// Units  - units
// Total
    // TotalAnnual
    // TotalMonthly
// Heating - 
    //HeatingAnnual
    //HeatingMonthly
// Cooling - 
    //CoolingAnnual
    //CoolingMonthly
// PlugLight - 
    //PlugLightAnnual
    //PlugLightMonthly
// Aux - 
    //AuxAnnual
    //AuxMonthly
// DHW - 
    //DHWAnnual
    //DHWMonthly


var modelID = dbinput.split(".json")[0].split("/")[1];

var parameters=[];
for (i=0;i<modelID.split(".").length;i++){
	parameters.push(modelID.split(".")[i]);
}

var result = {
    "ModelID": modelID,
    "Parameters":parameters,
    "Units": units,
    "Total":{
        "Annual":TotalAnnual,
        "Monthly":TotalMonthly,
    },
    "Heating":{
        "Annual":HeatingAnnual,
        "Monthly":HeatingMonthly,
    },
    "Cooling":{
        "Annual":CoolingAnnual,
        "Monthly":CoolingMonthly,
    },
    "PlugLight":{
        "Annual":PlugLightAnnual,
        "Monthly":PlugLightMonthly,
    },    
    "PumpFan":{
        "Annual":AuxAnnual,
        "Monthly":AuxMonthly,
    }  
   // "DHW":{
  //      "Annual":DHWAnnual,
   //     "Monthly":DHWMonthly,
   // },   
    
};

//console.log(result);

if (writefile==true){
fs.writeFile(outputFilename, JSON.stringify(result, null), function(err) {
    if(err) {
      console.log(err);
    } else {
      console.log("JSON saved.");
    }
}); 
}

if (dbresult==true){
    var mongo = require('mongodb'); 
mongo.connect(dbaddress, function(err, db) {
                    if(err) throw err;
            var collection = db.collection(dbcollection);
            collection.insert(result, function(err, docs) {
                console.log('Result Successfully Databased.')
                db.close();
        });
    }); 
}


});



