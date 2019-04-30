package be.ac.umons.bol.generator.sismic.specification;

import java.util.ArrayList;

import org.junit.Assert;
import org.junit.Test;

import be.ac.umons.bol.generator.sismic.specification.SpecificationState;

public class TestSpecificationState {
    String specification;
    SpecificationState specificationState;
    
    @Test
    public void testSpecificationState() {
        specification = "entry / raise MW.startHeating\n" +
                "every 1s / MW.duration -= 1\n" +
                "exit / raise MW.stopHeating";
        
        specificationState = new SpecificationState("test", specification);
        
        Assert.assertEquals(1, specificationState.getListEntryEvent().size());
        Assert.assertEquals("send(\"MW.startHeating\")", specificationState.getListEntryEvent().get(0));
        Assert.assertEquals(1, specificationState.getListExitEvent().size());
        Assert.assertEquals("send(\"MW.stopHeating\")", specificationState.getListExitEvent().get(0));
        Assert.assertTrue(specificationState.getEveryEvent() != null);
        Assert.assertEquals("test_every", specificationState.getEveryEvent().getNameState());
        Assert.assertEquals("MW.duration -= 1", specificationState.getEveryEvent().getActions().get(0));
    }
    
    @Test
    public void testSpecificationCookingMode() {
        specification = "entry /\n\t"
                + "heating_set(power);\n\t"
                + "raise heating_on;\n\t"
                + "raise lamp_on;\n\t"
                + "raise turntable_start\n"
                + "exit /\n\t"
                + "raise heating_off;\n\t"
                + "raise lamp_off;\n\t"
                + "raise turntable_stop\n"
                + "timer_tick / timer = timer + 1;\n\t"
                + "display_set(\"REMAINING: \", timer)";
        
        specificationState = new SpecificationState("cooking mode", specification);
        
        String[] expectedActionsInEntryEvent = {
                "heating_set(power)",
                "send(\"heating_on\")",
                "send(\"lamp_on\")",
                "send(\"turntable_start\")"
        };
        
        String[] expectedActionsInExitEvent = {
                "send(\"heating_off\")",
                "send(\"lamp_off\")",
                "send(\"turntable_stop\")"
        };
        
        Transition expectedTransition = new Transition("cooking mode", "timer_tick");
        expectedTransition.addAction("timer = timer + 1");
        expectedTransition.addAction("display_set(\"REMAINING: \", timer)");
        
        Assert.assertEquals(expectedActionsInEntryEvent.length, specificationState.getListEntryEvent().size());
        Assert.assertEquals(expectedActionsInExitEvent.length, specificationState.getListExitEvent().size());
        Assert.assertEquals(1, specificationState.getListOtherEvent().size());
        
        for (int i = 0; i < expectedActionsInEntryEvent.length; i++) {
            Assert.assertEquals(expectedActionsInEntryEvent[i], specificationState.getListEntryEvent().get(i));
        }
        
        for (int i = 0; i < expectedActionsInExitEvent.length; i++) {
            Assert.assertEquals(expectedActionsInExitEvent[i], specificationState.getListExitEvent().get(i));
        }
        
        Assert.assertEquals(expectedTransition.getEvent(), specificationState.getListOtherEvent().get(0).getEvent());
        Assert.assertEquals(expectedTransition.getListActions().size(), specificationState.getListOtherEvent().get(0).getListActions().size());
        for (int i = 0; i < expectedTransition.getListActions().size(); i++) {
            Assert.assertEquals(expectedTransition.getListActions().get(i), specificationState.getListOtherEvent().get(0).getListActions().get(i));
        }
    }
}
