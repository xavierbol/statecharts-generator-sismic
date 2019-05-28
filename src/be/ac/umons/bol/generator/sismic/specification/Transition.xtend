package be.ac.umons.bol.generator.sismic.specification

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.ArrayList

/**
 * Cette classe permet d'ajouter de nouvelle transition, lorsque l'on trouve à l'intérieur
 * d'un état un évènement always ou oncycle. Ces évènements seront traduits comme étant une
 * transition automatique vers le même état.
 * Attention, il faudra vérifier si ce même état ne contient pas déjà une transition automatique vers lui,
 * si c'est le cas, alors il faut ajouter les actions du always ou oncycle dans la transition automatique existante.
 */
class Transition {
	@Accessors String nameState
	@Accessors SpecificationTransition specification
	
	new(String name) {
		nameState = name
	}
	
	new(String name, String specification) {
		nameState = name
		this.specification = new SpecificationTransition(specification)
	}
	
	new(String name, SpecificationTransition specification) {
		this(name)
		this.specification = specification
	}
	
	new(String name, SpecificationTransition specification, String action) {
		this(name)
		this.specification = specification
		this.specification.addAction(action)
	}
	
	new(String name, String event, String guard, ArrayList<String> actions) {
		this(name)
		specification = new SpecificationTransition(event, guard, actions)
	}
	
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
	
	def generate() '''
		- target: «nameState»
		  «specification.generate»
	'''	
}