package be.ac.umons.bol.generator.sismic.specification;

import org.junit.Assert;
import org.junit.Test;

import be.ac.umons.bol.generator.sismic.specification.SpecificationRoot;

public class TestSpecificationRoot {
    private String specification;
    private SpecificationRoot sr;

    @Test
    public void testSpecification() {
        specification = "interface:\n\n"
                + "var current:integer // current floor\n"
                + "var destination:integer // destination floor\n"
                + "in event floorSelected : integer\n\n"
                + "operation openDoors():void\n"
                + "operation closeDoors():void";
        sr = new SpecificationRoot(specification);
        Assert.assertEquals(2, sr.getVariables().size());
        
        String[] expectedVariables = {"current = 0", "destination = 0"};
        
        for (int i = 0; i < expectedVariables.length; i++) {
            Assert.assertEquals(expectedVariables[i], sr.getVariables().get(i));
        }
        
        Assert.assertEquals(2, sr.getOperations().size());
        
        String[] expectedOperations = {"def openDoors() -> None:", "def closeDoors() -> None:"};
        
        for (int i = 0; i < expectedOperations.length; i++) {
            Assert.assertEquals(expectedOperations[i], sr.getOperations().get(i));
        }
        
        String[] expectedContext = {"openDoors", "closeDoors"};
        
        for (int i = 0; i < expectedContext.length; i++) {
            Assert.assertEquals(expectedContext[i], sr.getContext().get(i));
        }
    }
    
    @Test
    public void testSpecification2() {
        specification = "@EventDriven\n"
                + "// Use the event driven execution model.\n"
                + "// Runs a run-to-completion step\n"
                + "// each time an event is raised.\n"
                + "// Switch to cycle based behavior\n"
                + "// by specifying '@CycleBased(200)'\n"
                + "// instead.\n\n"
                + "@ChildFirstExecution\n"
                + "// In composite states, execute\n"
                + "// child states first.\n"
                + "// @ParentFirstExecution does the opposite.\n\n"
                + "interface:\n"
                + "in event start\n"
                + "in event stop\n"
                + "in event split\n"
                + "in event reset\n"
                + "in event test\n"
                + "var elapsed_time: real = 0\n"
                + "operation refresh(time : real) : void";
        
        sr = new SpecificationRoot(specification);
        
        Assert.assertEquals(1, sr.getVariables().size());
        Assert.assertEquals(1, sr.getOperations().size());
        
        String expectedVariable = "elapsed_time = 0";
        String expectedOperation = "def refresh(time: float) -> None:";
        
        Assert.assertEquals(expectedVariable, sr.getVariables().get(0));
        Assert.assertEquals(expectedOperation, sr.getOperations().get(0));
        
    }

    @Test
    public void testSpecificationInStatechartExample() {
        specification = "interface watch:\n"
                + "in event start\n"
                + "in event stop\n"
                + "in event split\n"
                + "in event unsplit\n"
                + "in event reset\n"
                + "var current: integer\n\n"
                + "internal:\n"
                + "operation resetDisplay() : void\n"
                + "operation ensureTimer() : void\n"
                + "operation syncDisplay() : void\n"
                + "operation freezeDisplay() : void\n"
                + "operation stopTimer() : void";
        
        sr = new SpecificationRoot(specification);
        
        String expectedVariable = "current = 0";
        String[] expectedOperations = {
                "def resetDisplay() -> None:", 
                "def ensureTimer() -> None:",
                "def syncDisplay() -> None:",
                "def freezeDisplay() -> None:",
                "def stopTimer() -> None:"
                };
        
        Assert.assertEquals(1, sr.getVariables().size());
        Assert.assertEquals(expectedOperations.length, sr.getOperations().size());
        
        Assert.assertEquals(expectedVariable, sr.getVariables().get(0));
        
        for (int i = 0; i < expectedOperations.length; i++) {
            Assert.assertEquals(expectedOperations[i], sr.getOperations().get(i));            
        }
    }
}
