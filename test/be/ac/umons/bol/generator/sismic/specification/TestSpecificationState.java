package be.ac.umons.bol.generator.sismic.specification;

import org.junit.Assert;
import org.junit.Test;

import be.ac.umons.bol.generator.sismic.specification.SpecificationState;

public class TestSpecificationState {
    String specification;
    SpecificationState specificationState;
    
    @Test
    public void testSpecificationState() {
        specification = "entry / raise MW.startHeating\n" +
                "every 1s / MW.duration -=1\n" +
                "exit / raise MW.stopHeating";
        
        specificationState = new SpecificationState("test", specification);
        
        Assert.assertEquals(1, specificationState.getListEntryEvent().size());
        Assert.assertEquals("send(\"MW.startHeating\")", specificationState.getListEntryEvent().get(0));
        Assert.assertEquals(1, specificationState.getListExitEvent().size());
        Assert.assertEquals("send(\"MW.stopHeating\")", specificationState.getListExitEvent().get(0));
        Assert.assertTrue(specificationState.getEveryEvent() != null);
        Assert.assertEquals("test_every", specificationState.getEveryEvent().getNameState());
        Assert.assertEquals("MW.duration -=1", specificationState.getEveryEvent().getActions().get(0));
    }
}
