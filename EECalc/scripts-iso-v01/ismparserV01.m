function [ In] = ismparserV01(ismfile)
%Parses the raw input cell array and assigns values to the input structure

% V0.01 29-Oct-2013
% started over from parse_inputparsing the current .ism file


if nargin==0
    %select the file with a gui
    [filename,pathname]=uigetfile('*.ism','Select Input .ism file to parse');
    switch filename
        case {0} 
            % User cancelled out, so quit with an error dialog
            error('User cancelled script run')
        otherwise
            ismfile=[pathname,filename]; 
    end % switch filename
end

fid=fopen(ismfile,'r');

if fid==-1
     error('File %s not found',file1)  % if fid==-1, file not found  so terminate with an error message
end

% parse the text file
while ~feof(fid)

    Inline=fgetl(fid);  % read in the text line by line into a single string array
    Inline2 = strtrim(Inline);   % strip off leading and trailing whitespace
    % skip blank lines, lines starting with a comment (#)  a lines with non-characters
    if isempty(Inline2) || strncmp(Inline2,'#',1) || ~ischar(Inline2)
        continue
    end
    % everything left should be of the form " A = B"
    [left,right] = strtok(Inline2,'=');
    left2=strtrim(left);
    value=str2num(right(2:end));   % convert everything to the right of the "=" to a number
    switch left2
        case 'weatherFilePath'
            In.weatherpath = right;
        case 'terrainClass'
            In.terrain_class= value;
        case 'buildingHeight'
            In.building_height = value;
        case 'floorArea'
            In.cond_flr_area = value;
        case 'peopleDensityOccupied'
            In.people_density_occ = value; 
        case 'peopleDensityUnoccupied'
            In.people_density_unocc = value;
        case 'buildingOccupancyFrom'        % day of week that occupancy starts
            In.occ_day_start = value;
        case 'buildingOccupancyTo'          % day of week that occupancy ends
            In.occ_day_end = value;
        case 'equivFullLoadOccupancyFrom'   % hour of day that occupancy starts
            In.occ_hour_start = value;
        case 'equivFullLoadOccupancyTo'     % hour of day that occupancy ends
            In.occ_hour_end = value;
        case 'lightingPowerIntensityOccupied'
            In.LPD_occ = value;
        case 'lightingPowerIntensityUnoccupied'
            In.LPD_unocc = value;
        case 'elecPowerAppliancesOccupied'
            In.elec_plug_dens_occ = value;
        case 'elecPowerAppliancesUnoccupied'
            In.elec_plug_dens_unocc = value ;
        case 'gasPowerAppliancesOccupied'
            In.gas_plug_dens_occ = value;
        case 'gasPowerAppliancesUnoccupied'
            In.gas_plug_dens_unocc = value;
        case 'exteriorLightingPower'
            In.E_lt_ext = value;
        case 'heatGainPerPerson'
            In.htgain_per_person = value;
        case 'heatingOccupiedSetpoint'
            In.ht_tset_occ = value;
        case 'heatingUnoccupiedSetpoint'
            In.ht_tset_unocc = value;
        case 'coolingOccupiedSetpoint'
            In.cl_tset_occ = value;
        case 'coolingUnoccupiedSetpoint'
            In.cl_tset_unocc = value;
        case 'hvacWasteFactor'
            In.hotcold_waste_factor = value;
        case 'hvacHeatingLossFactor'
            In.heat_loss_factor = value;
        case 'hvacCoolingLossFactor'
            In.cool_loss_factor = value;
        case 'daylightSensorSystem'
            In.daylighting_sensor=value;
        case 'lightingOccupancySensorSystem'
            In.lighting_occupancy_sensor=value;
        case 'constantIlluminationControl'
            In.lighting_constant_illumination=value;
        case 'coolingSystemCOP'
            In.COP = value;
        case 'coolingSystemIPLVToCopRatio'
            In.IPLVtoCOPratio = value;
        case 'heatingEnergyCarrier'
            In.heat_energy_type = value;
        case 'heatingSystemEfficiency'
             In.heat_sys_eff = value;
        case 'ventilationType'
            In.vent_type = value;
        case 'freshAirFlowRate'
            In.vent_supply_rate = value;
        case 'supplyExhaustRate'
          %In.vent_supply_diff = In.vent_supply_rate - value;  % this is the difference between input and exhaust  
          In.vent_exhaust = value;
        case 'heatRecovery'
            In.vent_heat_recovery = value;
        case 'exhaustAirRecirculation'     
            In.vent_recirc_fraction = value;
        case 'infiltration'
            In.infilt_rate = value;
        case 'dhwDemand'
           In.DHW_demand = value;
        case 'dhwSystemEfficiency'
            In.DHW_sys_eff = value;
        case 'dhwDistributionEfficiency'
            In.DHW_dist_eff = value;
        case 'dhwEnergyCarrier'
            In.DHW_energy_type = value;
        case 'interiorHeatCapacity'
            In.heat_capacity_int = value;
        case 'exteriorHeatCapacity' 
            In.heat_capacity_env = value;
        case 'bemType'
            In.BEM_type = value;
        case 'specificFanPower'
            In.fan_specific_power = value;
        case 'fanFlowcontrolFactor'
            In.fan_flow_ctrl_factor = value;
        case 'heatingPumpControl'
            In.pump_heat_ctrl_factor = value;
        case 'coolingPumpControl'
            In.pump_cool_ctrl_factor = value;
            
        % put the wall and window properties into arrays.  9th column of
        % wall array is the roof stuff
        % read in the envelope area information 
% making sure to put it into row arrays with columns being the different
%           directions in the order [S, SE, E, NE, N, NW, W, S
        case 'WallAreaS'
            In.wall_area(1) = value;
        case 'WallUvalueS'
            In.wall_U(1) = value;
        case 'WallSolarAbsorptionS'
            In.wall_solar_alpha(1) = value;
        case 'WallThermalEmissivityS'
            In.wall_thermal_emiss(1) = value;
        case 'WallAreaSE'
            In.wall_area(2) = value;
        case 'WallUvalueSE'
            In.wall_U(2) = value;
        case 'WallSolarAbsorptionSE'
            In.wall_solar_alpha(2) = value;
        case 'WallThermalEmissivitySE'
            In.wall_thermal_emiss(2) = value;            
        case 'WallAreaE'
            In.wall_area(3) = value;
        case 'WallUvalueE'
            In.wall_U(3) = value;
        case 'WallSolarAbsorptionE'
            In.wall_solar_alpha(3) = value;
        case 'WallThermalEmissivityE'
            In.wall_thermal_emiss(3) = value; 
        case 'WallAreaNE'
            In.wall_area(4) = value;
        case 'WallUvalueNE'
            In.wall_U(4) = value;
        case 'WallSolarAbsorptionNE'
            In.wall_solar_alpha(4) = value;
        case 'WallThermalEmissivityNE'
            In.wall_thermal_emiss(4) = value;     
        case 'WallAreaN'
            In.wall_area(5) = value;
        case 'WallUvalueN'
            In.wall_U(5) = value;
        case 'WallSolarAbsorptionN'
            In.wall_solar_alpha(5) = value;
        case 'WallThermalEmissivityN'
            In.wall_thermal_emiss(5) = value;             
        case 'WallAreaNW'
            In.wall_area(6) = value;
        case 'WallUvalueNW'
            In.wall_U(6) = value;
        case 'WallSolarAbsorptionNW'
            In.wall_solar_alpha(6) = value;
        case 'WallThermalEmissivityNW'
            In.wall_thermal_emiss(6) = value; 
        case 'WallAreaW'
            In.wall_area(6) = value;
        case 'WallUvalueW'
            In.wall_U(7) = value;
        case 'WallSolarAbsorptionW'
            In.wall_solar_alpha(7) = value;
        case 'WallThermalEmissivityW'
            In.wall_thermal_emiss(7) = value;
        case 'WallAreaSW'
            In.wall_area(8) = value;
        case 'WallUvalueSW'
            In.wall_U(8)= value;
        case 'WallSolarAbsorptionSW'
            In.wall_solar_alpha(8) = value;
        case 'WallThermalEmissivitySW'
            In.wall_thermal_emiss(8) = value; 
        case 'roofArea'
            In.wall_area(9) = value;
        case 'roofUValue'
            In.wall_U(9) = value;
        case 'roofSolarAbsorption'
            In.wall_solar_alpha(9) = value;
        case 'roofThermalEmissivity'
            In.wall_thermal_emiss(9) = value;            
        case 'WindowAreaS'
            In.win_area(1) = value;
        case 'WindowUvalueS'
            In.win_U(1) = value;
        case 'WindowSHGCS'
            In.win_SHGC(1) = value;
        case 'WindowSCFS'
            In.win_SCF(1) = value;
        case 'WindowSDFS'
            In.win_SDF(1) = value;    
        case 'WindowAreaSE'
            In.win_area(2) = value;
        case 'WindowUvalueSE'
            In.win_U(2) = value;
        case 'WindowSHGCSE'
            In.win_SHGC(2) = value;
        case 'WindowSCFSE'
            In.win_SCF(2) = value;  
        case 'WindowSDFSE'
            In.win_SDF(2) = value;           
        case 'WindowAreaE'
            In.win_area(3) = value;
        case 'WindowUvalueE'
            In.win_U(3) = value;
        case 'WindowSHGCE'
            In.win_SHGC(3) = value;
        case 'WindowSCFE'
            In.win_SCF(3) = value; 
        case 'WindowSDFE'
            In.win_SDF(3) = value;            
        case 'WindowAreaNE'
            In.win_area(4) = value;
        case 'WindowUvalueNE'
            In.win_U(4) = value;
        case 'WindowSHGCNE'
            In.win_SHGC(4) = value;
        case 'WindowSCFNE'
            In.win_SCF(4) = value;  
        case 'WindowSDFNE'
            In.win_SDF(4) = value;              
        case 'WindowAreaN'
            In.win_area(5) = value;
        case 'WindowUvalueN'
            In.win_U(5) = value;
        case 'WindowSHGCN'
            In.win_SHGC(5) = value;
        case 'WindowSCFN'
            In.win_SCF(5) = value;  
        case 'WindowSDFN'
            In.win_SDF(5) = value;             
        case 'WindowAreaNW'
            In.win_area(6) = value;
        case 'WindowUvalueNW'
            In.win_U(6) = value;
        case 'WindowSHGCNW'
            In.win_SHGC(6) = value;
        case 'WindowSCFNW'
            In.win_SCF(6) = value; 
        case 'WindowSDFNW'
            In.win_SDF(6) = value;             
        case 'WindowAreaW'
            In.win_area(7) = value;
        case 'WindowUvalueW'
            In.win_U(7) = value;
        case 'WindowSHGCW'
            In.win_SHGC(7) = value;
        case 'WindowSCFW'
            In.win_SCF(7) = value;
         case 'WindowSDFW'
            In.win_SDF(7) = value;           
        case 'WindowAreaSW'
            In.win_area(8) = value;
        case 'WindowUvalueSW'
            In.win_U(8)= value;
        case 'WindowSHGCSW'
            In.win_SHGC(8) = value;
        case 'WindowSCFSW'
            In.win_SCF(8) = value;
         case 'WindowSDFSW'
            In.win_SDF(8) = value;           
        case 'skylightArea'
            In.win_area(9) = value;
        case 'skylightUValue'
            In.win_U(9) = value;
        case 'skylightSHGC'
            In.win_SHGC(9) = value;
        case 'skylightSCF'
            In.win_SCF(9) = value;
        case 'skylightSDF';
            In.win_SDF(9) = value;
    end
end
fclose(fid)
return
