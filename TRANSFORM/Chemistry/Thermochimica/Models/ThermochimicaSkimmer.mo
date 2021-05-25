within TRANSFORM.Chemistry.Thermochimica.Models;
model ThermochimicaSkimmer "Off-gas separator based on Thermochimica-derived partial pressures"

  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium "Medium properties"
    annotation (choicesAllMatching=true);

  Fluid.Interfaces.FluidPort_Flow port_a(redeclare package Medium = Medium)
    "Fluid connector a (positive design flow direction is from port_a to port_b)" annotation (
      Placement(transformation(extent={{-120,-20},{-80,20}}, rotation=0), iconTransformation(extent={
            {-110,-10},{-90,10}})));
  Fluid.Interfaces.FluidPort_Flow port_b(redeclare package Medium = Medium)
    "Fluid connector b (positive design flow direction is from port_a to port_b)" annotation (
      Placement(transformation(extent={{80,-20},{120,20}}, rotation=0), iconTransformation(extent={{90,
            -10},{110,10}})));

  SI.Temperature T;

  parameter Boolean showName=true annotation (Dialog(tab="Visualization"));
  parameter Medium.MassFlowRate m_flow_small(min=0) = 1e-4
    "Regularization for zero flow:|m_flow| < m_flow_small" annotation (Dialog(tab="Advanced"));

  Boolean init;
  constant String filename="/home/max/proj/thermochimica/data/MSAX+CationVacancies.dat";
  constant String phaseNames[:]={"gas_ideal","LIQUsoln"};

  parameter SIadd.ExtraProperty C_start[Medium.nC]=fill(0,Medium.nC) annotation (Dialog(tab="Initialization"));

  parameter Boolean omitSpecies[Medium.nC]=fill(false,Medium.nC);
  parameter Real efficiency=1;

  parameter Real onTime=0;

  TRANSFORM.Chemistry.Thermochimica.BaseClasses.ThermochimicaOutput thermochimicaOutput=
      TRANSFORM.Chemistry.Thermochimica.Functions.RunAndGetMolesFluid(
      filename,
      T,
      port_a.p,
      C_input,
      Medium.extraPropertiesNames,
      phaseNames,
      init) "Thermochimica-derived mole fractions";

   SIadd.ExtraProperty C_input[Medium.nC](start=C_start)={Modelica.Fluid.Utilities.regStep(
       port_a.m_flow,
       port_b.C_outflow[i],
       port_a.C_outflow[i],
       m_flow_small) for i in 1:Medium.nC} "Trace substance mass-specific value";

   Real m_skimmed[Medium.nC](start=fill(0,Medium.nC),fixed=true);

protected
  Medium.Temperature T_a_inflow "Temperature of inflowing fluid at port_a";
  Medium.Temperature T_b_inflow
    "Temperature of inflowing fluid at port_b or T_a_inflow, if uni-directional flow";
equation
  T_a_inflow = Medium.temperature(Medium.setState_phX(
    port_b.p,
    port_b.h_outflow,
    port_b.Xi_outflow));
  T_b_inflow = Medium.temperature(Medium.setState_phX(
    port_a.p,
    port_a.h_outflow,
    port_a.Xi_outflow));
  T = Modelica.Fluid.Utilities.regStep(
    port_a.m_flow,
    T_a_inflow,
    T_b_inflow,
    m_flow_small);

  if time > 1 + onTime then
    init = false;
  else
    init = true;
  end if;

  port_a.m_flow + port_b.m_flow = 0;
  port_a.p = port_b.p;
  port_a.h_outflow = inStream(port_b.h_outflow);
  port_b.h_outflow = inStream(port_a.h_outflow);

  for i in 1:Medium.nC loop
    if omitSpecies[i] or time < onTime then
      port_a.C_outflow[i] = C_input[i];
      port_b.C_outflow[i] = C_input[i];
    else
      port_a.C_outflow[i] = (1-efficiency)*C_input[i] + efficiency*thermochimicaOutput.C[i];
      port_b.C_outflow[i] = (1-efficiency)*C_input[i] + efficiency*thermochimicaOutput.C[i];
    end if;
  end for;

  der(m_skimmed[:]) = port_a.C_outflow[:] * port_a.m_flow;

  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(coordinateSystem(
          preserveAspectRatio=false)));
end ThermochimicaSkimmer;
