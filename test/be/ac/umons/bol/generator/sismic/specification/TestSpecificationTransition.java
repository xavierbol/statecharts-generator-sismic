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
}
