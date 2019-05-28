package be.ac.umons.bol.generator.sismic.specification;

import static org.junit.Assert.assertArrayEquals;

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
        
        String[] expectedVariables = {"current = 0", "destination = 0"};
        String[] expectedOperations = {"def openDoors() -> None:", "def closeDoors() -> None:"};
        String[] expectedContext = {"openDoors", "closeDoors"};
        
        // Check interface
        Assert.assertEquals(1, sr.getListInterfaces().size());
        
        Interface _interface = sr.getListInterfaces().get(0);
        
        for (int i = 0; i < expectedVariables.length; i++) {
            Assert.assertEquals(expectedVariables[i], _interface.getVariables().get(i));
        }
        
        for (int i = 0; i < expectedOperations.length; i++) {
            Assert.assertEquals(expectedOperations[i], _interface.getOperations().get(i));
        }
        
        // Check the context        
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
        
        String[] expectedInterfaces = {
                ""
        };
        String[] expectedVariable = {
                "elapsed_time = 0"
        };
        String[] expectedOperation = {
                "def refresh(time: float) -> None:"
        };
        
        Assert.assertEquals(expectedInterfaces.length, sr.getListInterfaces().size());
        for (int i = 0; i < expectedInterfaces.length; i++) {
            Assert.assertEquals(expectedInterfaces[i], sr.getListInterfaces().get(i).getName());
        }
        
        Assert.assertArrayEquals(expectedVariable, sr.getListInterfaces().get(0).getVariables().toArray());
        Assert.assertArrayEquals(expectedOperation, sr.getListInterfaces().get(0).getOperations().toArray());
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
        
        String[] expectedInterfaces = {
                "watch"
        };
        String[] expectedVariables = {
                "current = 0"
        };
        String[] expectedOperations = {
                "def resetDisplay(self) -> None:", 
                "def ensureTimer(self) -> None:",
                "def syncDisplay(self) -> None:",
                "def freezeDisplay(self) -> None:",
                "def stopTimer(self) -> None:"
        };
        
        Assert.assertEquals(expectedInterfaces.length, sr.getListInterfaces().size());
        Assert.assertEquals(expectedInterfaces[0], sr.getListInterfaces().get(0).getName());
        Assert.assertEquals(expectedVariables.length, sr.getListInterfaces().get(0).getVariables().size());
        Assert.assertArrayEquals(expectedVariables, sr.getListInterfaces().get(0).getVariables().toArray());
        Assert.assertEquals(expectedOperations.length, sr.getListInterfaces().get(0).getOperations().size());
        Assert.assertArrayEquals(expectedOperations, sr.getListInterfaces().get(0).getOperations().toArray());
    }
    
    @Test
    public void testSpecificationMicrowave() {
        specification = "@EventDriven\n"
                + "@ChildFirstExecution\n\n"
                + "interface:\n"
                + "in event item_removed\n"
                + "in event item_placed\n\n"
                + "in event door_closed\n"
                + "in event door_opened\n\n"
                + "in event cooking_start\n"
                + "in event cooking_stop\n\n"
                + "in event lamp_on\n"
                + "in event lamp_off\n\n"
                + "in event timer_inc\n"
                + "in event timer_dec\n"
                + "in event timer_tick\n"
                + "in event timer_reset\n\n"
                + "in event heating_on\n"
                + "in event heating_off\n\n"
                + "in event turntable_start\n"
                + "in event turntable_stop\n\n"
                + "in event power_reset\n"
                + "in event power_inc\n"
                + "in event power_dec\n\n"
                + "in event display_clear\n\n"
                + "var power: integer\n"
                + "var POWER_DEFAULT: integer = 900\n"
                + "var MAX_POWER: integer = 1200\n"
                + "var timer: integer = 0\n\n"
                + "operation display(text: string)\n"
                + "operation display_set(text: string, number: integer)\n"
                + "operation heating_set(power: integer)\n"
                + "operation beep(number: integer)\n";
        
        sr = new SpecificationRoot(specification);
        
        String[] expectedEvents = {
                "item_removed", "item_placed",
                "door_closed", "door_opened",
                "cooking_start", "cooking_stop",
                "lamp_on", "lamp_off",
                "timer_inc", "timer_dec", "timer_tick", "timer_reset",
                "heating_on", "heating_off",
                "turntable_start", "turntable_stop",
                "power_reset", "power_inc", "power_dec",
                "display_clear"
        };
        
        String[] expectedInterfaces = {
                ""
        };
        
        String[] expectedVariables = {
                "power = 0",
                "POWER_DEFAULT = 900",
                "MAX_POWER = 1200",
                "timer = 0"
        };
        
        String[] expectedOperations = {
                "def display(text: str) -> None:",
                "def display_set(text: str, number: int) -> None:",
                "def heating_set(power: int) -> None:",
                "def beep(number: int) -> None:"
        };
        
        Assert.assertEquals(expectedInterfaces.length, sr.getListInterfaces().size());
        Assert.assertEquals(expectedInterfaces[0], sr.getListInterfaces().get(0).getName());
        Assert.assertArrayEquals(expectedVariables, sr.getListInterfaces().get(0).getVariables().toArray());
        Assert.assertArrayEquals(expectedOperations, sr.getListInterfaces().get(0).getOperations().toArray());
    }
    
    @Test
    public void testMultipleInterfaceInSpecification() {
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
                + "operation hello()\n"
                + "var coucou: integer\n"
                + "const constante: integer = 0\n\n"
                + "interface Bonjour:\n"
                + "var hello: integer\n"
                + "operation aurevoir()";
        
        sr = new SpecificationRoot(specification);
        
        // Check if we have the correct interface into the ArrayList
        String[] expectedInterfaces = {
                "", "Bonjour"
        };
        
        Assert.assertEquals(expectedInterfaces.length, sr.getListInterfaces().size());
        
        for (int i = 0; i < expectedInterfaces.length; i++) {
            Assert.assertEquals(expectedInterfaces[i], sr.getListInterfaces().get(i).getName());
        }
        
        // Check the content of first interface
        String[] expectedOperations = {
                "def hello() -> None:"
        };
        
        String[] expectedVariables = {
                "coucou = 0", "constante = 0"
        };
        
        Assert.assertEquals(expectedOperations.length, sr.getListInterfaces().get(0).getOperations().size());
        Assert.assertArrayEquals(expectedOperations, sr.getListInterfaces().get(0).getOperations().toArray());
        
        Assert.assertEquals(expectedVariables.length, sr.getListInterfaces().get(0).getVariables().size());
        Assert.assertArrayEquals(expectedVariables, sr.getListInterfaces().get(0).getVariables().toArray());
        
        // Check the content of second interfaces
        expectedOperations = new String[] {
                "def aurevoir(self) -> None:"
        };
        
        expectedVariables = new String[] {
                "hello = 0"
        };
        
        Assert.assertEquals(expectedOperations.length, sr.getListInterfaces().get(1).getOperations().size());
        Assert.assertArrayEquals(expectedOperations, sr.getListInterfaces().get(1).getOperations().toArray());
        
        Assert.assertEquals(expectedVariables.length, sr.getListInterfaces().get(1).getVariables().size());
        Assert.assertArrayEquals(expectedVariables, sr.getListInterfaces().get(1).getVariables().toArray());
    }
}
