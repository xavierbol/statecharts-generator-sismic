package be.ac.umons.bol.generator.sismic.specification;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class TestSpecification {
	private String specification;
	private Specification spec;
	
	@Test
	public void testSpecificationInState() {
		specification = "power_inc [power <= 1200] /\n" + 
    			"	power = power + 300;\n" + 
    			"	display_set(\"POWER: \", power)\n";
		
		spec = new Specification(specification);
		
		String expectedEvent = "power_inc";
		String expectedGuard = "power <= 1200";
		String[] expectedActions = {
				"power = power + 300",
				"display_set(\"POWER: \", power)"
		};
		
		assertEquals(expectedEvent, spec.getEvent());
		assertEquals(expectedGuard, spec.getGuard());
		assertTrue(spec.getListActions().size() == expectedActions.length);
		
		for (int i = 0; i < expectedActions.length; i++) {
			assertEquals(expectedActions[i], spec.getListActions().get(i));
		}
	}
	
	@Test
	public void testSpecification() {
		specification = "every 5s / coucou";
		
		spec = new Specification(specification);
		String expectedEvent = "every 5s";
		String expectedAction = "coucou";
		
		assertEquals(expectedEvent, spec.getEvent());
		assertEquals(expectedAction, spec.getListActions().get(0));
		
		specification = "oncycle [coucou]";
		spec = new Specification(specification);
		
		expectedEvent = "oncycle";
		String expectedGuard = "coucou";
		
		assertEquals(expectedEvent, spec.getEvent());
		assertEquals(expectedGuard, spec.getGuard());
	}
	
	@Test
	public void testSpecificationInTransition() {
		
	}
}
