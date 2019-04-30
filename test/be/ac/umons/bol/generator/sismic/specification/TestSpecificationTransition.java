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
}
