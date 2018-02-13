within TRANSFORM.Nuclear.ReactorKinetics.Examples;
model PointKinetics_Drift_Test_feedback
  extends
    TRANSFORM.Nuclear.ReactorKinetics.Examples.PointKinetics_Drift_Test_flat(
      core_kinetics(specifyPower=false));

  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(StopTime=100000000, __Dymola_NumberOfIntervals=10000));
end PointKinetics_Drift_Test_feedback;
