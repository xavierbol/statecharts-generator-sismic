package be.ac.umons.bol.generator.sismic.specification;

import org.junit.Test;
import static org.junit.Assert.assertEquals;

public class TestSpecificationTransition {
	String specification;
	SpecificationTransition st;
	
	@Test
	public void testSpecificationTransition() {
		specification = "after 5s [currentFloor > 0] / floor =0";
		
		st = new SpecificationTransition(specification);
		
		System.out.println(st.getGuard());
		
		if (st.getListActions() != null && !st.getListActions().isEmpty()) {
			for (String action : st.getListActions())
				System.out.println(action);			
		}
		
		assertEquals("", st.getEvent());
		assertEquals("currentFloor > 0 && after(5.0)", st.getGuard());
		assertEquals("floor =0", st.getListActions().get(0));
	}
}
