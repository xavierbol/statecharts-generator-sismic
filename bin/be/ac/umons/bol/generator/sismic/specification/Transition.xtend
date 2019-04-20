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
	@Accessors ArrayList<String> listActions
	
	new(String name) {
		nameState = name
		listActions = new ArrayList
	}
	
	new(String name, ArrayList<String> actions) {
		nameState = name
		listActions = actions
	}
	
	def addAction(String action) {
		listActions.add(action)
	}
	
	def generate() '''
		- target: «nameState»
		«IF listActions.size > 0»
			«IF listActions.size == 1»
				action: «listActions.get(0)»
			«ELSE»
				action: |
				«FOR action : listActions»
					«action»
				«ENDFOR»
			«ENDIF»
		«ENDIF»
	'''	
}