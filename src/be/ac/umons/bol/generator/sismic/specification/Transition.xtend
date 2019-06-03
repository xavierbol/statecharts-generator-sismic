package be.ac.umons.bol.generator.sismic.specification

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.ArrayList

/**
 * Français :
 * Cette classe permet d'ajouter de nouvelle transition, lorsque l'on trouve à l'intérieur
 * d'un état un évènement always ou oncycle, ou un évènement créé par l'utilisateur. 
 * Ces évènements seront traduits comme étant une
 * transition automatique vers le même état.
 * 
 * English : 
 * This class add a new transition for statechart defined in Sismic, when we find a event 
 * with keyword «always» or «oncycle» or a event created by user in a state.
 * This events are translated into a self transition to the same state.
 */
class Transition {
	@Accessors String nameState
	@Accessors SpecificationTransition specification
	
	/**
	 * Constructor
	 * 
	 * @param name : the name of state
	 */
	new(String name) {
		nameState = name
	}
	
	/**
	 * Constructor
	 * 
	 * @param name : the name of state
	 * @param specification : contains the event and/or guard
	 */
	new(String name, String specification) {
		nameState = name
		this.specification = new SpecificationTransition(specification)
	}
	
	/**
	 * Constructor
	 * 
	 * @param name : the name of state
	 * @param specification : the instance of SpecificationTransition for the current object
	 */
	new(String name, SpecificationTransition specification) {
		this(name)
		this.specification = specification
	}
	
	/**
	 * Constructor
	 * 
	 * @param name : the name of state
	 * @param specification : the instance of SpecificationTransition for the current object
	 */
	new(String name, SpecificationTransition specification, String action) {
		this(name, specification)
		this.specification.addAction(action)
	}
	
	/**
	 * Constructor
	 * Only use to facilitate the unit test
	 * 
	 * @param name : the name of state
	 * @param event : the name of event
	 * @param guard : the guard
	 * @param actions : the list of actions to add
	 */
	new(String name, String event, String guard, ArrayList<String> actions) {
		this(name)
		specification = new SpecificationTransition(event, guard, actions)
	}
	
	/**
	 * Add an action into the list of actions.
	 * 
	 * @param action : the action to add
	 */
	def addAction(String action) {
		specification.addAction(action)
	}
	
	override equals(Object obj) {
		if (obj instanceof Transition) {
            val temp = obj as Transition;
            if (nameState.equals(temp.nameState) && specification.equals(temp.specification)) {
                return true;
            }
        }

        return false;
	}
	
	/**
	 * Generate the transition for a statechart defined in Sismic.
	 */
	def generate() '''
		- target: «nameState»
		  «specification.generate»
	'''	
}