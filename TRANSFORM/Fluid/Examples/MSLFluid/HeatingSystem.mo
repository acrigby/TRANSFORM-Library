within TRANSFORM.Fluid.Examples.MSLFluid;
model HeatingSystem "Simple model of a heating system"
  extends TRANSFORM.Icons.Example;
   replaceable package Medium =
      Modelica.Media.Water.StandardWater
     constrainedby Modelica.Media.Interfaces.PartialMedium;
  Modelica.Fluid.Vessels.OpenTank tank(
    redeclare package Medium = Medium,
    crossArea=0.01,
    height=2,
    level_start=1,
    nPorts=2,
    massDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial,
    use_HeatTransfer=true,
    portsData={Modelica.Fluid.Vessels.BaseClasses.VesselPortsData(diameter=
        0.01),Modelica.Fluid.Vessels.BaseClasses.VesselPortsData(diameter=
        0.01)},
    redeclare model HeatTransfer =
        Modelica.Fluid.Vessels.BaseClasses.HeatTransfer.IdealHeatTransfer (k=10),
    ports(each p(start=1e5)),
    T_start=Modelica.SIunits.Conversions.from_degC(20))
              annotation (Placement(transformation(extent={{-80,30},{-60,50}})));
  TRANSFORM.Fluid.Valves.ValveIncompressible valve(
    redeclare package Medium = Medium,
    CvData=Modelica.Fluid.Types.CvTypes.OpPoint,
    m_flow_nominal=0.01,
    show_T=true,
    allowFlowReversal=false,
    dp_start=18000,
    dp_nominal=10000)
    annotation (Placement(transformation(extent={{60,-80},{40,-60}})));
protected
  Modelica.Blocks.Interfaces.RealOutput m_flow
    annotation (Placement(transformation(extent={{-6,34},{6,46}})));
public
  TRANSFORM.Fluid.Sensors.MassFlowRate sensor_m_flow(redeclare package Medium =
        Medium)
    annotation (Placement(transformation(extent={{-20,10},{0,30}})));
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature T_ambient(T=system.T_ambient)
    annotation (Placement(transformation(extent={{-14,-27},{0,-13}})));
  Modelica.Thermal.HeatTransfer.Components.ThermalConductor wall(G=1.6e3/20)
    annotation (Placement(transformation(
        origin={10,-48},
        extent={{8,-10},{-8,10}},
        rotation=90)));
  Modelica.Thermal.HeatTransfer.Sources.FixedHeatFlow burner(
                                                     Q_flow=1.6e3,
    T_ref=343.15,
    alpha=-0.5)
    annotation (Placement(transformation(extent={{16,30},{36,50}})));
  inner Modelica.Fluid.System system(
      m_flow_small=1e-4, energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyStateInitial)
                        annotation (Placement(transformation(extent={{-90,70},{
            -70,90}})));
Pipes.GenericPipe_MultiTransferSurface
                  heater(
    redeclare package Medium = Medium,
    use_HeatTransfer=true,
    energyDynamics=system.energyDynamics,
    m_flow_a_start=system.m_flow_start,
    redeclare model Geometry =
        ClosureRelations.Geometry.Models.DistributedVolume_1D.StraightPipe (
                                                          dimension=0.01,
          length=2),
    exposeState_a=false,
    momentumDynamics=system.momentumDynamics,
    p_a_start=130000,
    T_a_start=353.15,
    redeclare model HeatTransfer =
        ClosureRelations.HeatTransfer.Models.DistributedPipe_1D_MultiTransferSurface.Ideal)
    annotation (Placement(transformation(extent={{30,10},{50,30}})));
Pipes.GenericPipe_MultiTransferSurface
                  radiator(
    redeclare package Medium = Medium,
    use_HeatTransfer=true,
    energyDynamics=system.energyDynamics,
    m_flow_a_start=system.m_flow_start,
    redeclare model Geometry =
        ClosureRelations.Geometry.Models.DistributedVolume_1D.StraightPipe (
                                                          dimension=0.01,
          length=10),
    momentumDynamics=system.momentumDynamics,
    exposeState_a=false,
    p_a_start=110000,
    T_a_start=313.15,
    redeclare model HeatTransfer =
        ClosureRelations.HeatTransfer.Models.DistributedPipe_1D_MultiTransferSurface.Ideal)
    annotation (Placement(transformation(extent={{20,-80},{0,-60}})));
protected
  Modelica.Blocks.Interfaces.RealOutput T_forward
    annotation (Placement(transformation(extent={{74,34},{86,46}})));
  Modelica.Blocks.Interfaces.RealOutput T_return
    annotation (Placement(transformation(extent={{-46,-56},{-58,-44}})));
public
  TRANSFORM.Fluid.Sensors.Temperature sensor_T_forward(redeclare package Medium =
        Medium)
    annotation (Placement(transformation(extent={{50,30},{70,50}})));
  TRANSFORM.Fluid.Sensors.Temperature sensor_T_return(redeclare package Medium =
        Medium)
    annotation (Placement(transformation(extent={{-20,-60},{-40,-40}})));
protected
  Modelica.Blocks.Interfaces.RealOutput tankLevel
                                 annotation (Placement(transformation(extent={{-56,34},
            {-44,46}})));
public
  Modelica.Blocks.Sources.Step handle(
    startTime=2000,
    height=0.9,
    offset=0.1)   annotation (Placement(transformation(extent={{26,-27},{40,-13}})));
Pipes.GenericPipe_MultiTransferSurface
                  pipe(
    redeclare package Medium = Medium,
    energyDynamics=system.energyDynamics,
    m_flow_a_start=system.m_flow_start,
    exposeState_b=true,
    momentumDynamics=system.momentumDynamics,
    p_a_start=130000,
    T_a_start=353.15,
    redeclare model Geometry =
        ClosureRelations.Geometry.Models.DistributedVolume_1D.StraightPipe (
        dimension=0.01,
        length=10,
        nV=2)) annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=-90,
        origin={80,-20})));
  Utilities.ErrorAnalysis.UnitTests unitTests(
    name="HeatingSystem_T",
    errorExpected=2,
    n=3,
    x={heater.mediums[1].T,radiator.mediums[1].T,pipe.mediums[1].p},
    x_reference=cat(
        1,
        timeTable_pipe2_T.y,
        timeTable_pipe2_p.y))
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
  Modelica.Blocks.Sources.CombiTimeTable timeTable_pipe2_T(smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative, table=[0,
        344.798,296.573; 12,344.798,296.573; 24,344.798,296.573; 36,344.798,296.573;
        48,344.798,296.573; 60,344.798,296.573; 72,344.798,296.573; 84,344.798,
        296.573; 96,344.798,296.573; 108,344.798,296.573; 120,344.798,296.573;
        132,344.798,296.573; 144,344.798,296.573; 156,344.798,296.573; 168,344.798,
        296.573; 180,344.798,296.573; 192,344.798,296.573; 204,344.798,296.573;
        216,344.798,296.573; 228,344.798,296.573; 240,344.798,296.573; 252,344.798,
        296.573; 264,344.798,296.573; 276,344.798,296.573; 288,344.798,296.573;
        300,344.798,296.573; 312,344.798,296.573; 324,344.798,296.573; 336,344.798,
        296.573; 348,344.798,296.573; 360,344.798,296.573; 372,344.798,296.573;
        384,344.798,296.573; 396,344.798,296.573; 408,344.798,296.573; 420,344.798,
        296.573; 432,344.798,296.573; 444,344.798,296.573; 456,344.798,296.573;
        468,344.798,296.573; 480,344.798,296.573; 492,344.798,296.573; 504,344.798,
        296.573; 516,344.798,296.573; 528,344.798,296.573; 540,344.798,296.573;
        552,344.798,296.573; 564,344.798,296.573; 576,344.798,296.573; 588,344.798,
        296.573; 600,344.798,296.573; 612,344.798,296.573; 624,344.798,296.573;
        636,344.798,296.573; 648,344.798,296.573; 660,344.798,296.573; 672,344.798,
        296.573; 684,344.798,296.573; 696,344.798,296.573; 708,344.798,296.573;
        720,344.798,296.573; 732,344.798,296.573; 744,344.798,296.573; 756,344.798,
        296.573; 768,344.798,296.573; 780,344.798,296.573; 792,344.798,296.573;
        804,344.798,296.573; 816,344.798,296.573; 828,344.798,296.573; 840,344.798,
        296.573; 852,344.798,296.573; 864,344.798,296.573; 876,344.798,296.573;
        888,344.798,296.573; 900,344.798,296.573; 912,344.798,296.573; 924,344.798,
        296.573; 936,344.798,296.573; 948,344.798,296.573; 960,344.798,296.573;
        972,344.798,296.573; 984,344.798,296.573; 996,344.798,296.573; 1008,344.798,
        296.573; 1020,344.798,296.573; 1032,344.798,296.573; 1044,344.798,296.573;
        1056,344.798,296.573; 1068,344.798,296.573; 1080,344.798,296.573; 1092,
        344.798,296.573; 1104,344.798,296.573; 1116,344.798,296.573; 1128,344.798,
        296.573; 1140,344.798,296.573; 1152,344.798,296.573; 1164,344.798,296.573;
        1176,344.798,296.573; 1188,344.798,296.573; 1200,344.798,296.573; 1212,
        344.798,296.573; 1224,344.798,296.573; 1236,344.798,296.573; 1248,344.798,
        296.573; 1260,344.798,296.573; 1272,344.798,296.573; 1284,344.798,296.573;
        1296,344.798,296.573; 1308,344.798,296.573; 1320,344.798,296.573; 1332,
        344.798,296.573; 1344,344.798,296.573; 1356,344.798,296.573; 1368,344.798,
        296.573; 1380,344.798,296.573; 1392,344.798,296.573; 1404,344.798,296.573;
        1416,344.798,296.573; 1428,344.798,296.573; 1440,344.798,296.573; 1452,
        344.798,296.573; 1464,344.798,296.573; 1476,344.798,296.573; 1488,344.798,
        296.573; 1500,344.798,296.573; 1512,344.798,296.573; 1524,344.798,296.573;
        1536,344.798,296.573; 1548,344.798,296.573; 1560,344.798,296.573; 1572,
        344.798,296.573; 1584,344.798,296.573; 1596,344.798,296.573; 1608,344.798,
        296.573; 1620,344.798,296.573; 1632,344.798,296.573; 1644,344.798,296.573;
        1656,344.798,296.573; 1668,344.798,296.573; 1680,344.798,296.573; 1692,
        344.798,296.573; 1704,344.798,296.573; 1716,344.798,296.573; 1728,344.798,
        296.573; 1740,344.798,296.573; 1752,344.798,296.573; 1764,344.798,296.573;
        1776,344.798,296.573; 1788,344.798,296.573; 1800,344.798,296.573; 1812,
        344.798,296.573; 1824,344.798,296.573; 1836,344.798,296.573; 1848,344.798,
        296.573; 1860,344.798,296.573; 1872,344.798,296.573; 1884,344.798,296.573;
        1896,344.798,296.573; 1908,344.798,296.573; 1920,344.798,296.573; 1932,
        344.798,296.573; 1944,344.798,296.573; 1956,344.798,296.573; 1968,344.798,
        296.573; 1980,344.798,296.573; 1992,344.798,296.573; 2000,344.798,296.573;
        2004,341.949,299.247; 2016,341.943,305.075; 2028,341.955,308.565; 2040,
        341.969,310.61; 2052,341.985,311.794; 2064,342.002,312.463; 2076,342.018,
        312.83; 2088,342.035,313.022; 2100,342.051,313.118; 2112,342.067,313.153;
        2124,342.083,313.154; 2136,342.099,313.15; 2148,342.114,313.141; 2160,
        342.129,313.132; 2172,342.144,313.125; 2184,342.158,313.119; 2196,342.172,
        313.115; 2208,342.186,313.113; 2220,342.2,313.113; 2232,342.214,313.114;
        2244,342.227,313.117; 2256,342.24,313.12; 2268,342.253,313.124; 2280,342.266,
        313.129; 2292,342.278,313.134; 2304,342.29,313.14; 2316,342.302,313.145;
        2328,342.314,313.151; 2340,342.326,313.157; 2352,342.337,313.162; 2364,
        342.349,313.168; 2376,342.36,313.174; 2388,342.371,313.179; 2400,342.381,
        313.184; 2412,342.392,313.189; 2424,342.402,313.194; 2436,342.412,313.199;
        2448,342.423,313.203; 2460,342.432,313.208; 2472,342.442,313.212; 2484,
        342.452,313.216; 2496,342.461,313.22; 2508,342.47,313.224; 2520,342.479,
        313.228; 2532,342.488,313.232; 2544,342.497,313.236; 2556,342.506,313.24;
        2568,342.514,313.244; 2580,342.523,313.247; 2592,342.531,313.251; 2604,
        342.539,313.255; 2616,342.547,313.258; 2628,342.555,313.262; 2640,342.563,
        313.265; 2652,342.57,313.269; 2664,342.578,313.272; 2676,342.585,313.276;
        2688,342.592,313.279; 2700,342.6,313.282; 2712,342.607,313.285; 2724,342.613,
        313.288; 2736,342.62,313.292; 2748,342.627,313.295; 2760,342.633,313.298;
        2772,342.64,313.301; 2784,342.646,313.304; 2796,342.652,313.307; 2808,
        342.659,313.309; 2820,342.665,313.312; 2832,342.671,313.315; 2844,342.676,
        313.318; 2856,342.682,313.32; 2868,342.688,313.323; 2880,342.693,313.325;
        2892,342.699,313.328; 2904,342.704,313.33; 2916,342.71,313.333; 2928,342.715,
        313.335; 2940,342.72,313.338; 2952,342.725,313.34; 2964,342.73,313.342;
        2976,342.735,313.344; 2988,342.74,313.347; 3000,342.744,313.349; 3012,
        342.749,313.351; 3024,342.753,313.353; 3036,342.758,313.355; 3048,342.762,
        313.357; 3060,342.767,313.359; 3072,342.771,313.361; 3084,342.775,313.363;
        3096,342.779,313.365; 3108,342.783,313.367; 3120,342.787,313.368; 3132,
        342.791,313.37; 3144,342.795,313.372; 3156,342.799,313.374; 3168,342.803,
        313.375; 3180,342.807,313.377; 3192,342.81,313.379; 3204,342.814,313.38;
        3216,342.817,313.382; 3228,342.821,313.383; 3240,342.824,313.385; 3252,
        342.827,313.387; 3264,342.831,313.388; 3276,342.834,313.39; 3288,342.837,
        313.391; 3300,342.84,313.392; 3312,342.843,313.394; 3324,342.846,313.395;
        3336,342.849,313.397; 3348,342.852,313.398; 3360,342.855,313.399; 3372,
        342.858,313.4; 3384,342.861,313.402; 3396,342.864,313.403; 3408,342.866,
        313.404; 3420,342.869,313.405; 3432,342.872,313.407; 3444,342.874,313.408;
        3456,342.877,313.409; 3468,342.879,313.41; 3480,342.882,313.411; 3492,
        342.884,313.412; 3504,342.887,313.413; 3516,342.889,313.414; 3528,342.891,
        313.415; 3540,342.894,313.416; 3552,342.896,313.418; 3564,342.898,313.419;
        3576,342.9,313.419; 3588,342.902,313.42; 3600,342.904,313.421; 3612,342.907,
        313.422; 3624,342.909,313.423; 3636,342.911,313.424; 3648,342.913,313.425;
        3660,342.914,313.426; 3672,342.916,313.427; 3684,342.918,313.428; 3696,
        342.92,313.429; 3708,342.922,313.429; 3720,342.924,313.43; 3732,342.925,
        313.431; 3744,342.927,313.432; 3756,342.929,313.433; 3768,342.93,313.433;
        3780,342.932,313.434; 3792,342.934,313.435; 3804,342.935,313.436; 3816,
        342.937,313.436; 3828,342.938,313.437; 3840,342.94,313.438; 3852,342.941,
        313.438; 3864,342.942,313.439; 3876,342.944,313.44; 3888,342.945,313.44;
        3900,342.947,313.441; 3912,342.948,313.441; 3924,342.949,313.442; 3936,
        342.951,313.443; 3948,342.952,313.443; 3960,342.953,313.444; 3972,342.954,
        313.444; 3984,342.956,313.445; 3996,342.957,313.445; 4008,342.958,313.446;
        4020,342.959,313.446; 4032,342.96,313.447; 4044,342.961,313.447; 4056,
        342.962,313.448; 4068,342.964,313.448; 4080,342.965,313.449; 4092,342.966,
        313.449; 4104,342.967,313.45; 4116,342.968,313.45; 4128,342.969,313.451;
        4140,342.97,313.451; 4152,342.971,313.452; 4164,342.971,313.452; 4176,
        342.972,313.452; 4188,342.973,313.453; 4200,342.974,313.453; 4212,342.975,
        313.454; 4224,342.976,313.454; 4236,342.977,313.454; 4248,342.978,313.455;
        4260,342.978,313.455; 4272,342.979,313.456; 4284,342.98,313.456; 4296,
        342.981,313.456; 4308,342.982,313.457; 4320,342.982,313.457; 4332,342.983,
        313.457; 4344,342.984,313.458; 4356,342.985,313.458; 4368,342.985,313.458;
        4380,342.986,313.459; 4392,342.987,313.459; 4404,342.987,313.459; 4416,
        342.988,313.46; 4428,342.989,313.46; 4440,342.989,313.46; 4452,342.99,
        313.46; 4464,342.991,313.461; 4476,342.991,313.461; 4488,342.992,313.461;
        4500,342.992,313.462; 4512,342.993,313.462; 4524,342.994,313.462; 4536,
        342.994,313.462; 4548,342.995,313.463; 4560,342.995,313.463; 4572,342.996,
        313.463; 4584,342.996,313.463; 4596,342.997,313.464; 4608,342.997,313.464;
        4620,342.998,313.464; 4632,342.999,313.464; 4644,342.999,313.465; 4656,
        343,313.465; 4668,343,313.465; 4680,343,313.465; 4692,343.001,313.465;
        4704,343.001,313.466; 4716,343.002,313.466; 4728,343.002,313.466; 4740,
        343.003,313.466; 4752,343.003,313.466; 4764,343.004,313.467; 4776,343.004,
        313.467; 4788,343.004,313.467; 4800,343.005,313.467; 4812,343.005,313.467;
        4824,343.006,313.467; 4836,343.006,313.468; 4848,343.006,313.468; 4860,
        343.007,313.468; 4872,343.007,313.468; 4884,343.007,313.468; 4896,343.008,
        313.469; 4908,343.008,313.469; 4920,343.009,313.469; 4932,343.009,313.469;
        4944,343.009,313.469; 4956,343.01,313.469; 4968,343.01,313.469; 4980,343.01,
        313.47; 4992,343.01,313.47; 5004,343.011,313.47; 5016,343.011,313.47;
        5028,343.011,313.47; 5040,343.012,313.47; 5052,343.012,313.47; 5064,343.012,
        313.471; 5076,343.013,313.471; 5088,343.013,313.471; 5100,343.013,313.471;
        5112,343.013,313.471; 5124,343.014,313.471; 5136,343.014,313.471; 5148,
        343.014,313.471; 5160,343.014,313.472; 5172,343.015,313.472; 5184,343.015,
        313.472; 5196,343.015,313.472; 5208,343.015,313.472; 5220,343.016,313.472;
        5232,343.016,313.472; 5244,343.016,313.472; 5256,343.016,313.472; 5268,
        343.017,313.472; 5280,343.017,313.473; 5292,343.017,313.473; 5304,343.017,
        313.473; 5316,343.017,313.473; 5328,343.018,313.473; 5340,343.018,313.473;
        5352,343.018,313.473; 5364,343.018,313.473; 5376,343.018,313.473; 5388,
        343.019,313.473; 5400,343.019,313.473; 5412,343.019,313.474; 5424,343.019,
        313.474; 5436,343.019,313.474; 5448,343.019,313.474; 5460,343.02,313.474;
        5472,343.02,313.474; 5484,343.02,313.474; 5496,343.02,313.474; 5508,343.02,
        313.474; 5520,343.02,313.474; 5532,343.021,313.474; 5544,343.021,313.474;
        5556,343.021,313.474; 5568,343.021,313.475; 5580,343.021,313.475; 5592,
        343.021,313.475; 5604,343.022,313.475; 5616,343.022,313.475; 5628,343.022,
        313.475; 5640,343.022,313.475; 5652,343.022,313.475; 5664,343.022,313.475;
        5676,343.022,313.475; 5688,343.022,313.475; 5700,343.023,313.475; 5712,
        343.023,313.475; 5724,343.023,313.475; 5736,343.023,313.475; 5748,343.023,
        313.475; 5760,343.023,313.475; 5772,343.023,313.476; 5784,343.023,313.476;
        5796,343.024,313.476; 5808,343.024,313.476; 5820,343.024,313.476; 5832,
        343.024,313.476; 5844,343.024,313.476; 5856,343.024,313.476; 5868,343.024,
        313.476; 5880,343.024,313.476; 5892,343.024,313.476; 5904,343.024,313.476;
        5916,343.025,313.476; 5928,343.025,313.476; 5940,343.025,313.476; 5952,
        343.025,313.476; 5964,343.025,313.476; 5976,343.025,313.476; 5988,343.025,
        313.476; 6000,343.025,313.476])
    annotation (Placement(transformation(extent={{50,80},{70,100}})));
  Modelica.Blocks.Sources.CombiTimeTable timeTable_pipe2_p(smoothness=Modelica.Blocks.Types.Smoothness.ContinuousDerivative, table=[0,
        129992; 12,129992; 24,129992; 36,129992; 48,129992; 60,129992; 72,129992;
        84,129992; 96,129992; 108,129992; 120,129992; 132,129992; 144,129992;
        156,129992; 168,129992; 180,129992; 192,129992; 204,129992; 216,129992;
        228,129992; 240,129992; 252,129992; 264,129992; 276,129992; 288,129992;
        300,129992; 312,129992; 324,129992; 336,129992; 348,129992; 360,129992;
        372,129992; 384,129992; 396,129992; 408,129992; 420,129992; 432,129992;
        444,129992; 456,129992; 468,129992; 480,129992; 492,129992; 504,129992;
        516,129992; 528,129992; 540,129992; 552,129992; 564,129992; 576,129992;
        588,129992; 600,129992; 612,129992; 624,129992; 636,129992; 648,129992;
        660,129992; 672,129992; 684,129992; 696,129992; 708,129992; 720,129992;
        732,129992; 744,129992; 756,129992; 768,129992; 780,129992; 792,129992;
        804,129992; 816,129992; 828,129992; 840,129992; 852,129992; 864,129992;
        876,129992; 888,129992; 900,129992; 912,129992; 924,129992; 936,129992;
        948,129992; 960,129992; 972,129992; 984,129992; 996,129992; 1008,129992;
        1020,129992; 1032,129992; 1044,129992; 1056,129992; 1068,129992; 1080,
        129992; 1092,129992; 1104,129992; 1116,129992; 1128,129992; 1140,129992;
        1152,129992; 1164,129992; 1176,129992; 1188,129992; 1200,129992; 1212,
        129992; 1224,129992; 1236,129992; 1248,129992; 1260,129992; 1272,129992;
        1284,129992; 1296,129992; 1308,129992; 1320,129992; 1332,129992; 1344,
        129992; 1356,129992; 1368,129992; 1380,129992; 1392,129992; 1404,129992;
        1416,129992; 1428,129992; 1440,129992; 1452,129992; 1464,129992; 1476,
        129992; 1488,129992; 1500,129992; 1512,129992; 1524,129992; 1536,129992;
        1548,129992; 1560,129992; 1572,129992; 1584,129992; 1596,129992; 1608,
        129992; 1620,129992; 1632,129992; 1644,129992; 1656,129992; 1668,129992;
        1680,129992; 1692,129992; 1704,129992; 1716,129992; 1728,129992; 1740,
        129992; 1752,129992; 1764,129992; 1776,129992; 1788,129992; 1800,129992;
        1812,129992; 1824,129992; 1836,129992; 1848,129992; 1860,129992; 1872,
        129992; 1884,129992; 1896,129992; 1908,129992; 1920,129992; 1932,129992;
        1944,129992; 1956,129992; 1968,129992; 1980,129992; 1992,129992; 2000,
        129992; 2000.61,129888; 2004,129888; 2016,129888; 2028,129888; 2040,129889;
        2052,129889; 2064,129889; 2076,129889; 2088,129890; 2100,129890; 2112,
        129890; 2124,129890; 2136,129891; 2148,129891; 2160,129891; 2172,129891;
        2184,129891; 2196,129892; 2208,129892; 2220,129892; 2232,129892; 2244,
        129892; 2256,129892; 2268,129893; 2280,129893; 2292,129893; 2304,129893;
        2316,129893; 2328,129893; 2340,129893; 2352,129893; 2364,129894; 2376,
        129894; 2388,129894; 2400,129894; 2412,129894; 2424,129894; 2436,129894;
        2448,129894; 2460,129894; 2472,129894; 2484,129894; 2496,129894; 2508,
        129895; 2520,129895; 2532,129895; 2544,129895; 2556,129895; 2568,129895;
        2580,129895; 2592,129895; 2604,129895; 2616,129895; 2628,129895; 2640,
        129895; 2652,129895; 2664,129895; 2676,129895; 2688,129895; 2700,129895;
        2712,129895; 2724,129895; 2736,129895; 2748,129895; 2760,129895; 2772,
        129896; 2784,129896; 2796,129896; 2808,129896; 2820,129896; 2832,129896;
        2844,129896; 2856,129896; 2868,129896; 2880,129896; 2892,129896; 2904,
        129896; 2916,129896; 2928,129896; 2940,129896; 2952,129896; 2964,129896;
        2976,129896; 2988,129896; 3000,129896; 3012,129896; 3024,129896; 3036,
        129896; 3048,129896; 3060,129896; 3072,129896; 3084,129896; 3096,129896;
        3108,129896; 3120,129896; 3132,129896; 3144,129896; 3156,129896; 3168,
        129896; 3180,129896; 3192,129896; 3204,129896; 3216,129896; 3228,129896;
        3240,129896; 3252,129896; 3264,129896; 3276,129896; 3288,129896; 3300,
        129896; 3312,129896; 3324,129896; 3336,129896; 3348,129896; 3360,129896;
        3372,129896; 3384,129896; 3396,129896; 3408,129896; 3420,129896; 3432,
        129896; 3444,129896; 3456,129896; 3468,129896; 3480,129896; 3492,129896;
        3504,129896; 3516,129896; 3528,129896; 3540,129896; 3552,129896; 3564,
        129896; 3576,129896; 3588,129896; 3600,129896; 3612,129896; 3624,129896;
        3636,129896; 3648,129896; 3660,129896; 3672,129896; 3684,129896; 3696,
        129896; 3708,129896; 3720,129896; 3732,129896; 3744,129896; 3756,129896;
        3768,129896; 3780,129896; 3792,129896; 3804,129896; 3816,129896; 3828,
        129896; 3840,129896; 3852,129896; 3864,129896; 3876,129896; 3888,129896;
        3900,129896; 3912,129896; 3924,129896; 3936,129896; 3948,129896; 3960,
        129896; 3972,129896; 3984,129896; 3996,129896; 4008,129896; 4020,129896;
        4032,129896; 4044,129896; 4056,129896; 4068,129896; 4080,129896; 4092,
        129896; 4104,129896; 4116,129896; 4128,129896; 4140,129896; 4152,129896;
        4164,129896; 4176,129896; 4188,129896; 4200,129896; 4212,129896; 4224,
        129896; 4236,129896; 4248,129896; 4260,129896; 4272,129896; 4284,129896;
        4296,129896; 4308,129896; 4320,129896; 4332,129896; 4344,129896; 4356,
        129896; 4368,129896; 4380,129896; 4392,129896; 4404,129896; 4416,129896;
        4428,129896; 4440,129896; 4452,129896; 4464,129896; 4476,129896; 4488,
        129896; 4500,129896; 4512,129896; 4524,129896; 4536,129896; 4548,129896;
        4560,129896; 4572,129896; 4584,129896; 4596,129896; 4608,129896; 4620,
        129896; 4632,129896; 4644,129896; 4656,129896; 4668,129896; 4680,129896;
        4692,129896; 4704,129896; 4716,129896; 4728,129896; 4740,129896; 4752,
        129896; 4764,129896; 4776,129896; 4788,129896; 4800,129896; 4812,129896;
        4824,129896; 4836,129896; 4848,129896; 4860,129896; 4872,129896; 4884,
        129896; 4896,129896; 4908,129896; 4920,129896; 4932,129896; 4944,129896;
        4956,129896; 4968,129896; 4980,129896; 4992,129896; 5004,129896; 5016,
        129896; 5028,129896; 5040,129896; 5052,129896; 5064,129896; 5076,129896;
        5088,129896; 5100,129896; 5112,129896; 5124,129896; 5136,129896; 5148,
        129896; 5160,129896; 5172,129896; 5184,129896; 5196,129896; 5208,129896;
        5220,129896; 5232,129896; 5244,129896; 5256,129896; 5268,129896; 5280,
        129896; 5292,129896; 5304,129896; 5316,129896; 5328,129896; 5340,129896;
        5352,129896; 5364,129896; 5376,129896; 5388,129896; 5400,129896; 5412,
        129896; 5424,129896; 5436,129896; 5448,129896; 5460,129896; 5472,129896;
        5484,129896; 5496,129896; 5508,129896; 5520,129896; 5532,129896; 5544,
        129896; 5556,129896; 5568,129896; 5580,129896; 5592,129896; 5604,129896;
        5616,129896; 5628,129896; 5640,129896; 5652,129896; 5664,129896; 5676,
        129896; 5688,129896; 5700,129896; 5712,129896; 5724,129896; 5736,129896;
        5748,129896; 5760,129896; 5772,129896; 5784,129896; 5796,129896; 5808,
        129896; 5820,129896; 5832,129896; 5844,129896; 5856,129896; 5868,129896;
        5880,129896; 5892,129896; 5904,129896; 5916,129896; 5928,129896; 5940,
        129896; 5952,129896; 5964,129896; 5976,129896; 5988,129896; 6000,129896])
    annotation (Placement(transformation(extent={{20,80},{40,100}})));
  Machines.Pump pump(
    redeclare package Medium = Medium,
    N_nominal=1500,
    use_T_start=true,
    T_start=Modelica.SIunits.Conversions.from_degC(40),
    m_flow_start=0.01,
    m_flow_nominal=0.01,
    V=0,
    redeclare model EfficiencyChar =
        TRANSFORM.Fluid.ClosureRelations.PumpCharacteristics.Models.Efficiency.Constant
        (eta_constant=0.8),
    exposeState_a=false,
    exposeState_b=true,
    energyDynamics=Modelica.Fluid.Types.Dynamics.SteadyState,
    p_a_start=110000,
    p_b_start=130000,
    dp_nominal=20000,
    controlType="pressure")
    annotation (Placement(transformation(extent={{-50,10},{-30,30}})));
equation
tankLevel = tank.level;
  connect(sensor_m_flow.m_flow, m_flow)         annotation (Line(points={{-10,
          23.6},{-10,40},{0,40}},               color={0,0,127}));
  connect(sensor_m_flow.port_b, heater.port_a)
                                            annotation (Line(points={{0,20},{0,
          20},{30,20}},
                    color={0,127,255}));
  connect(T_ambient.port, wall.port_a)                       annotation (Line(
        points={{0,-20},{10,-20},{10,-40}}, color={191,0,0}));
  connect(sensor_T_forward.T, T_forward)     annotation (Line(points={{66,40},{
          80,40}},                              color={0,0,127}));
  connect(radiator.port_a, valve.port_b) annotation (Line(points={{20,-70},{20,
          -70},{40,-70}},           color={0,127,255}));
  connect(sensor_T_return.port, radiator.port_b)
                                            annotation (Line(points={{-30,-60},
          {-30,-70},{0,-70}}, color={0,127,255}));
  connect(handle.y, valve.opening)       annotation (Line(
      points={{40.7,-20},{50,-20},{50,-62}},
      color={0,0,127}));
  connect(sensor_T_return.T, T_return)        annotation (Line(
      points={{-36,-50},{-52,-50}},
      color={0,0,127}));
  connect(sensor_T_forward.port, heater.port_b)
                                              annotation (Line(
      points={{60,30},{60,20},{50,20}},
      color={0,127,255}));
  connect(heater.port_b, pipe.port_a) annotation (Line(
      points={{50,20},{80,20},{80,-10}},
      color={0,127,255}));
  connect(pipe.port_b, valve.port_a) annotation (Line(
      points={{80,-30},{80,-70},{60,-70}},
      color={0,127,255}));
  connect(radiator.port_b, tank.ports[1]) annotation (Line(
      points={{0,-70},{-72,-70},{-72,30}},
      color={0,127,255}));
  connect(pump.port_a, tank.ports[2]) annotation (Line(points={{-50,20},{-68,20},
          {-68,30}}, color={0,127,255}));
  connect(pump.port_b, sensor_m_flow.port_a) annotation (Line(points={{-30,20},
          {-25,20},{-20,20}}, color={0,127,255}));
  connect(burner.port, heater.heatPorts[1, 1])
    annotation (Line(points={{36,40},{40,40},{40,25}}, color={191,0,0}));
  connect(radiator.heatPorts[1, 1], wall.port_b)
    annotation (Line(points={{10,-65},{10,-56}}, color={191,0,0}));
  annotation (                             Documentation(info="<html>
<p>
Simple heating system with a closed flow cycle.
After 2000s of simulation time the valve fully opens. A simple idealized control is embedded
into the respective components, so that the heating system can be regulated with the valve:
the pump controls the pressure, the burner controls the temperature.
</p>
<p>
One can investigate the temperatures and flows for different settings of <code>system.energyDynamics</code>
(see Assumptions tab of the system object).</p>
<ul>
<li>With <code>system.energyDynamics==Types.Dynamics.FixedInitial</code> the states need to find their steady values during the simulation.</li>
<li>With <code>system.energyDynamics==Types.Dynamics.SteadyStateInitial</code> (default setting) the simulation starts in steady-state.</li>
<li>With <code>system.energyDynamics==Types.Dynamics.SteadyState</code> all but one dynamic states are eliminated.
    The left state <code>tank.m</code> is to account for the closed flow cycle. It is constant as outflow and inflow are equal
    in a steady-state simulation.</li>
</ul>
<p>
Note that a closed flow cycle generally causes circular equalities for the mass flow rates and leaves the pressure undefined.
This is why the tank.massDynamics, i.e., the tank level determining the port pressure, is modified locally to Types.Dynamics.FixedInitial.
</p>
<p>
Also note that the tank is thermally isolated against its ambient. This way the temperature of the tank is also
well defined for zero flow rate in the heating system, e.g., for valveOpening.offset=0 at the beginning of a simulation.
The pipe however is assumed to be perfectly isolated.
If steady-state values shall be obtained with the valve fully closed, then a thermal
coupling between the pipe and its ambient should be defined as well.
</p>
<p>
Moreover it is worth noting that the idealized direct connection between the heater and the pipe, resulting in equal port pressures,
is treated as high-index DAE, as opposed to a nonlinear equation system for connected pressure loss correlations. A pressure loss correlation
could be additionally introduced to model the fitting between the heater and the pipe, e.g., to adapt different diameters.
</p>

<img src=\"modelica://Modelica/Resources/Images/Fluid/Examples/HeatingSystem.png\" border=\"1\"
     alt=\"HeatingSystem.png\">
</html>"), experiment(StopTime=6000),
    __Dymola_Commands(file(ensureSimulated=true)=
        "modelica://Modelica/Resources/Scripts/Dymola/Fluid/HeatingSystem/plotResults.mos"
        "plotResults"));
end HeatingSystem;
