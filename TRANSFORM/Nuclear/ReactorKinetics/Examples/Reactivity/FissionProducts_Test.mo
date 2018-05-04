within TRANSFORM.Nuclear.ReactorKinetics.Examples.Reactivity;
model FissionProducts_Test
  import TRANSFORM;

  extends TRANSFORM.Icons.Example;

  TRANSFORM.Nuclear.ReactorKinetics.Reactivity.FissionProducts_withDecayHeat
    fissionProducts(
    nC=data.nC,
    nFS=data.nFS,
    parents=data.parents,
    sigmasA=data.sigmaA_thermal,
    lambdas=data.lambdas,
    w_near_decay=data.w_near_decay,
    w_far_decay=data.w_far_decay,
    fissionYields=data.fissionYield_t,
    traceDynamics=Modelica.Fluid.Types.Dynamics.FixedInitial)
    annotation (Placement(transformation(extent={{-10,-10},{10,10}})));
  TRANSFORM.Nuclear.ReactorKinetics.Data.FissionProducts.fissionProducts_TeIXe_U235
    data annotation (Placement(transformation(extent={{-10,30},{10,50}})));
  Utilities.ErrorAnalysis.UnitTests unitTests(n=3, x=fissionProducts.mCs[1, :])
    annotation (Placement(transformation(extent={{80,80},{100,100}})));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end FissionProducts_Test;
