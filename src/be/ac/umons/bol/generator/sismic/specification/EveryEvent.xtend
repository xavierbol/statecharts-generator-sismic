package be.ac.umons.bol.generator.sismic.specification

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.ArrayList

/**
 * Français :
 * Cette classe permet de faciliter la génération de l'évènement every des statecharts
 * vers un statechart exploitable pour la librairie sismic
 * 
 * English :
 * This class allow to facilitate the generation of «every» event of statecharts 
 * into a suitable statechart for the Sismic library.
 */
class EveryEvent {
	static String EVERY = "_every"
	
	@Accessors float time
	@Accessors String nameState
	@Accessors String guard
	@Accessors ArrayList<String> actions
	
	/**
	 * Constructor
	 * 
	 * @param name : the name of state
	 * @param time : the time of the temporal event
	 */
	new(String name, float time) {
		this.time = time
		nameState = name + EVERY
		actions = new ArrayList
	}
	
	/**
	 * Constructor
	 * 
	 * @param name : the name of state
	 * @param time : the time of the temporal event
	 * @param actions : the list of actions released by «every» event
	 */
	new(String name, float time, ArrayList<String> actions) {
		this(name, time)
		this.actions = actions
	}
	
	/**
	 * Add action into the list of actions
	 */
	def addAction(String action) {
		actions.add(action)			
	}
	
	/**
	 * Generate the translate the temporal event («every») for a statechart defined in Sismic
	 * 
	 * @return String, the template for statechart in Sismic. 
	 */
	def generate() '''
		initial: «nameState»
		states:
			- name: «nameState»
			  transitions:
			  	- target: «nameState»
			  	  guard: after(«time») and «guard»
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