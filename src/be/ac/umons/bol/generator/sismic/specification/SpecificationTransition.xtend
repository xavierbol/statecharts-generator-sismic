package be.ac.umons.bol.generator.sismic.specification

import java.util.ArrayList

class SpecificationTransition extends Specification {
	
	new(String specification) {
		super(specification)
	}
	
	new(String event, String guard, ArrayList<String> actions) {
		super(event, guard, actions)
	}
	
	def mergeSpecification(SpecificationTransition specification) {
		this.listActions.addAll(specification.listActions)
	}
	
	/**
	 * Generate the data extracted in the specification of the outgoingTransition tag.
	 */
	def CharSequence generate() '''
		«IF !event.empty»
			event: «event»
		«ENDIF»
		«IF !guard.empty»
			guard: «guard»
		«ENDIF»
		«IF listActions !== null && !listActions.empty»
			«IF listActions.length == 1»
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