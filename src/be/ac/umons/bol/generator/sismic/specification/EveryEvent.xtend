package be.ac.umons.bol.generator.sismic.specification

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.ArrayList

/**
 * Cette classe permet de faciliter la génération de l'évènement every des statecharts
 * vers un statechart exploitable pour la librairie sismic
 */
class EveryEvent {
	static String EVERY = "_every"
	@Accessors float time
	@Accessors String nameState
	@Accessors ArrayList<String> actions
	
	new(String name, float time) {
		this.time = time
		nameState = name + EVERY
	}
	
	new(String name, float time, ArrayList<String> actions) {
		this(name, time)
		this.actions = actions
	}
	
	def addAction(String action) {
		if (actions === null) actions = new ArrayList
		actions.add(action)	
	}
	
	def generate() '''
		initial: «nameState»
		states:
			- name: «nameState»
			  transitions:
			  	- target: «nameState»
			  	  guard: after(«time»)
			  	  «IF actions.length == 1»
			  	  	action: «actions.get(0)»
			  	  «ELSE»
			  	  	action: |
			  	  		«FOR action : actions»
			  	  			«action»
			  	  		«ENDFOR»
			  	  «ENDIF»
	'''
}