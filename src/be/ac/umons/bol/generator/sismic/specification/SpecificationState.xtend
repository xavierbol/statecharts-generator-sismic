package be.ac.umons.bol.generator.sismic.specification

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.ArrayList
import java.util.regex.Pattern

enum Event {
	ENTRY, EXIT,
	ALWAYS, EVERY, ONCYCLE
}

class SpecificationState {
	@Accessors String nameState
	// List containing all actions according to the type of the event
	@Accessors ArrayList<String> listEntryEvent
	@Accessors ArrayList<String> listExitEvent
	@Accessors Transition transition
	@Accessors EveryEvent everyEvent
	
	new(String name, String specifications) {
		nameState = name
		if (specifications !== null) {
			retrieveSpecifications(specifications)			
		}
	}
	
	private def retrieveSpecifications(String specifications) {
		val tabSpecifications = specifications.split('\n')
		
		var Event lastEvent = null
		for (specification : tabSpecifications) {
			val tab = specification.split('/')
			
			if (tab.length == 1) { // alors il n'y a pas de / dans la chaine de caractères
				addAction(lastEvent, tab.get(0).trim())
			} else {
				lastEvent = defineEvent(tab.get(0).trim())
				addAction(lastEvent, tab.get(1).trim())
			}
		}
	}
	
	/**
	 * Define the type of event
	 * 
	 * @param event is the event extracted in the state to search its type
	 * 
	 * @return the type of this event
	 */
	private def defineEvent(String event) {
		if (event.equals("entry")) {
			if (listEntryEvent === null) {
				listEntryEvent = new ArrayList
			}
			return Event.ENTRY
		}
		
		if (event.equals("exit")) {
			if (listExitEvent === null) {
				listExitEvent = new ArrayList
			}
			return Event.EXIT
		}
		
		if (event.equals("always")) {
			if (transition === null) {
				transition = new Transition(nameState)
			}
			return Event.ALWAYS
		}
		
		if (event.contains("every")) {
			manageEveryEvent(event)
			return Event.EVERY
		}
		
		if (event.equals("oncycle")) {
			if (transition === null) {
				transition = new Transition(nameState)
			}
			return Event.ONCYCLE
		}
		
		return null
	}
	
	/**
	 * Extract the raise keyword in an action given in parameter
	 * In Sismic, the raise keyword must be transformed by send(...)
	 * 
	 * @param action is the action to extract the raise keyword
	 */
	private def extractRaiseAction(String action) {
		if (action.matches("raise\\s*(.*)")) {
            return action.replaceAll("raise\\s*(.*)", "send(\"$1\")");
        }
        
        return action
	}
	
	/**
	 * Add an action into the correct list according to the type of event
	 * containing the action
	 * 
	 * @param event is the type of the event containing the action
	 * @param action is the action to add into a list
	 */
	private def addAction(Event event, String action) {
		var a = extractRaiseAction(action)
		
        switch (event) {
            case ENTRY:
                listEntryEvent.add(a)
            case EXIT:
                listExitEvent.add(a)
            case ALWAYS:
                transition.addAction(a)
            case EVERY:
                everyEvent.addAction(a)
            case ONCYCLE:
                transition.addAction(a)
        }
	}
	
	/**
	 * Manage the every event because Sismic doesn't have every event.
	 * If this event is containing into this current, then we must add a new region
	 * into this state. In this region, a new state is created with a self transition
	 * where it contains after keyword as guard.
	 * 
	 * @param event is the current event to find and manage the eventual every event
	 */
	private def manageEveryEvent(String event) {
		var regex = "every (\\d+)(ms|s|m|h)";
        var p = Pattern.compile(regex);
        var m = p.matcher(event);
		
		if (m.find()) { // if it's a temporal event with keyword after... then it must to change into after(...)
            var eventTime = m.group(0);
            var value = Float.valueOf(m.group(1));
            var timeUnit = m.group(2);

            switch (timeUnit) {
                case "ms":
                    value = value / 1000
                case "m":
                    value = value * 60
                case "h":
                    value = value * 60 * 24
            }
            
            everyEvent = new EveryEvent(nameState, value)
        }
	}
	
	/**
	 * Generate the extracted data into this current state
	 * The onecycle, always and every event aren't generated here
	 */
	def generate() '''
	  «IF listEntryEvent !== null && listEntryEvent.length > 0»
	  	«IF listEntryEvent.length == 1»
	  		on entry: «listEntryEvent.get(0)»
	  	«ELSE»
		on entry: |
			«FOR entryEvent : listEntryEvent»
				«entryEvent»
			«ENDFOR»
	  	«ENDIF»
	  «ENDIF»
	  «IF listExitEvent !== null && listExitEvent.length > 0»
		«IF listExitEvent.length == 1»
			on exit: «listExitEvent.get(0)»
		«ELSE»
			on exit: |
		  		«FOR exitEvent : listExitEvent»
					«exitEvent»
				«ENDFOR»
		«ENDIF»
	  «ENDIF»
	'''
}