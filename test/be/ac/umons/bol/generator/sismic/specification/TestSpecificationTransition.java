package be.ac.umons.bol.generator.sismic.specification;

import org.junit.Test;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class TestSpecificationTransition {
	String specification;
	SpecificationTransition st;
	
	@Test
	public void testSpecificationTransition() {
		specification = "after 5s [currentFloor > 0] / floor =0";
		
		st = new SpecificationTransition(specification);
		
		assertEquals("", st.getEvent());
		assertEquals("currentFloor > 0 and after(5.0)", st.getGuard());
		assertEquals("floor =0", st.getListActions().get(0));
	}
	
	@Test
	public void testSpecificationTransitionEvent() {
		specification = "openDoors";
		
		st = new SpecificationTransition(specification);
		
		assertEquals("openDoors", st.getEvent());
		assertEquals("", st.getGuard());
		assertTrue(st.getListActions().isEmpty());
	}
	
	@Test
	public void testActions() {
	    specification = "/floor = 0; currentFloor = 0";
	    st = new SpecificationTransition(specification);
	    
	    String[] expectedActions = {"floor = 0", "currentFloor = 0"};
	    
	    assertEquals(expectedActions.length, st.getListActions().size());
	    
	    for (int i = 0; i < expectedActions.length; i++) {
	        assertEquals(expectedActions[i], st.getListActions().get(i));
	    }
	}
	
	@Test
	public void testExtractEventAndGuard() {
	    specification = "floorSelected\n[floor> currentFloor]";
	    st = new SpecificationTransition(specification);
	    
	    assertTrue(st.getEvent() != null && !st.getEvent().isEmpty());
	    assertEquals("floorSelected", st.getEvent());
	    assertTrue(st.getGuard()!= null && !st.getGuard().isEmpty());
	    assertEquals("floor> currentFloor", st.getGuard());
	    
	    specification = "floorSelected\n[floor < currentFloor && floor >=0]";
	    st = new SpecificationTransition(specification);
	    
	    assertTrue(st.getEvent() != null && !st.getEvent().isEmpty());
	    assertEquals("floorSelected", st.getEvent());
	    assertTrue(st.getGuard()!= null && !st.getGuard().isEmpty());
	    assertEquals("floor < currentFloor and floor >=0", st.getGuard());
	}
	
	@Test
    public void testSpecificationInState() {
        specification = "power_inc [power <= 1200] /\n" + 
                "   power = power + 300;\n" + 
                "   display_set(\"POWER: \", power)\n";
        
        st = new SpecificationTransition(specification);
        
        String expectedEvent = "power_inc";
        String expectedGuard = "power <= 1200";
        String[] expectedActions = {
                "power = power + 300",
                "display_set(\"POWER: \", power)"
        };
        
        assertEquals(expectedEvent, st.getEvent());
        assertEquals(expectedGuard, st.getGuard());
        assertTrue(st.getListActions().size() == expectedActions.length);
        
        for (int i = 0; i < expectedActions.length; i++) {
            assertEquals(expectedActions[i], st.getListActions().get(i));
        }
    }
    
    @Test
    public void testSpecification() {
        specification = "every 5s / coucou";
        
        st = new SpecificationTransition(specification);
        String expectedEvent = "every 5s";
        String expectedAction = "coucou";
        
        assertEquals(expectedEvent, st.getEvent());
        assertEquals(expectedAction, st.getListActions().get(0));
        
        specification = "oncycle [coucou]";
        st = new SpecificationTransition(specification);
        
        expectedEvent = "oncycle";
        String expectedGuard = "coucou";
        
        assertEquals(expectedEvent, st.getEvent());
        assertEquals(expectedGuard, st.getGuard());
    }
}
