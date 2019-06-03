package be.ac.umons.bol.generator.sismic.specification

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.ArrayList
import java.util.regex.Pattern

enum Event {
	ENTRY, EXIT,
	ALWAYS, EVERY, ONCYCLE
}

/**
 * Français :
 * Cette classe gère le contenu de l'attribut specification dans la balise "Vertex" (Etat)
 * 
 * English : 
 * This class manage the contains of the specification attribute in the "Vertex" tag (State)
 */
class SpecificationState {
	@Accessors String nameState
	@Accessors ArrayList<String> listEntryEvent
	@Accessors ArrayList<String> listExitEvent
	@Accessors ArrayList<Transition> listOtherEvent
	@Accessors Transition transition
	@Accessors EveryEvent everyEvent
	
	/**
	 * Constructor
	 * 
	 * @param name : the name of state
	 * @param specifications : the contains of specification attribute in a State
	 */
	new(String name, String specifications) {
		nameState = name
		if (specifications !== null && !specifications.empty) {
			retrieveSpecifications(specifications)			
		}
	}
	
	/**
	 * retrieve all events, guards and actions in the specification attribute of a State in the statechart of Yakindu
	 * 
	 * @param specifications : the contains of specification attribute of a state to extract data.
	 */
	private def retrieveSpecifications(String specifications) {
		val tabSpecifications = specifications.replaceAll('\t', '').split('\n')
		
		var Event lastEvent = null
		var event = ""
		
		for (specification : tabSpecifications) {
			val tab = specification.split('/')
			
			if (tab.length == 1) {
				if (specification.contains('/') || lastEvent === null && event.empty) {
					event = tab.get(0).trim()
					lastEvent = defineEvent(event)
				} else {
					if (lastEvent === null) {
						manageActions(event, tab.get(0).trim())
					} else {
						manageActions(lastEvent, tab.get(0).trim())					
					}					
				}
			} else {
				if (!tab.get(0).trim().empty) {
					event = tab.get(0).trim()
					lastEvent = defineEvent(event)
				}
				
				if (lastEvent === null) {
					manageActions(event, tab.get(1).trim())
				} else {
					manageActions(lastEvent, tab.get(1).trim())
				}
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
			if (event.contains("[")) {
				throw new Exception("Error, sismic doesn't support guard into entry event")
			}
			
			if (listEntryEvent === null) {
				listEntryEvent = new ArrayList
			}
			return Event.ENTRY
		}
		
		if (event.contains("exit")) {
			if (event.contains("[")) {
				throw new Exception("Error, sismic doesn't support guard into exit event")
			}
			
			if (listExitEvent === null) {
				listExitEvent = new ArrayList
			}
			return Event.EXIT
		}
		
		if (event.contains("always")) {
			if (transition === null) {
				transition = new Transition(nameState, event.replaceAll("always", ""))
			}
			return Event.ALWAYS
		}
		
		if (event.contains("every")) {
			manageEveryEvent(event)
			return Event.EVERY
		}
		
		if (event.contains("oncycle")) {
			if (transition === null) {
				transition = new Transition(nameState, event.replaceAll("oncycle", ""))
			}
			return Event.ONCYCLE
		}
		
		return null
	}
	
	/**
	 * manage the gathered actions in the specification attribute
	 * 
	 * @param event : the event that it release the actions. This event correspond to enum @see{Event}
	 * @param action : the actions to extract 
	 */
	private def manageActions(Event event, String action) {
		val a = treatActions(action)
		if (action.contains(";")) {
            val tabActions = a.split(";");

            for (elem : tabActions) {
                addAction(event, elem.trim());
            }
        } else {
            addAction(event, a);
        }
	}
	
	/**
	 * manage the actions of other events that are defined by user
	 * 
	 * @param event : the corresponding event, this event can contains 
	 * @param action the actions to extract
	 */
	private def manageActions(String event, String action) {
		val specification = new SpecificationTransition(event)
		var transition = searchTransition(specification)
		
		if (transition === null) {
			transition = new Transition(nameState, specification, action)
			
			if (listOtherEvent === null) {
	        	listOtherEvent = new ArrayList
	        }
	        
	        listOtherEvent.add(transition)
		} else {
			transition.addAction(action)
		}
	}
	
	/**
	 * search if it exist an instance of SpecificationTransition with the same event and guard in the listOtherEvent
	 * if yes, then return this instance, otherwise return null
	 * 
	 * @param the instance of SpecificationTransition to search if another instance in the list doesn't contain the same trigger (event and guard)
	 * 
	 * @return the SpecificationTransition instance containing the same event and guard than the instance in parameter, return null if it doesn't find.
	 */
	private def searchTransition(SpecificationTransition specification) {
		if (listOtherEvent !== null) {
			for (var i = 0; i < listOtherEvent.size(); i++) {
				if (listOtherEvent.get(i).specification.haveSameTrigger(specification)) {
					return listOtherEvent.get(i)
				}
			}
		}
		
		return null
	}
	
	private def treatActions(String action) {
        var a = action.replaceAll("\\btrue\\b", "True") // replace true by True
        a = a.replaceAll("\\bfalse\\b", "False") // replace false by False
        a = a.replaceAll("raise\\s*(\\w+\\.*\\w*);?", "send(\"$1\")")
        a = a.replaceAll("\\bvalueof\\s*\\((\\w+)\\)\\s*", "event.$1")
        
        return a
    }
	
	/**
	 * Add an action into the correct list according to the type of event
	 * containing the action
	 * 
	 * @param event is the type of the event containing the action
	 * @param action is the action to add into a list
	 */
	private def addAction(Event event, String action) {		
        switch (event) {
            case ENTRY:
                listEntryEvent.add(action)
            case EXIT:
                listExitEvent.add(action)
            case ALWAYS:
                transition.addAction(action)
            case EVERY:
                everyEvent.addAction(action)
            case ONCYCLE:
                transition.addAction(action)
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
		var regex = "every (\\d+)(ms|s|m|h)(.*)";
        var p = Pattern.compile(regex);
        var m = p.matcher(event);
		
		if (m.find()) { // if it's a temporal event with keyword after... then it must to change into after(...)
            var eventTime = m.group(0);
            var value = Float.valueOf(m.group(1));
            var timeUnit = m.group(2);
            var guard = m.group(3);

            switch (timeUnit) {
                case "ms":
                    value = value / 1000
                case "m":
                    value = value * 60
                case "h":
                    value = value * 60 * 24
            }
            
            everyEvent = new EveryEvent(nameState, value)
            
            if (guard !== null) {
            	guard = treatGuard(guard)
            	everyEvent.guard = guard
            }
        }
	}
	
	private def treatGuard(String guard) {
		var g = guard.replaceAll("\\[|\\]", "").trim()
		g = g.replaceAll("(\\s)&&(\\s)", "$1and$2") // replace && by and
        g = g.replaceAll("(\\s)\\|\\|(\\s)", "$1or$2") // replace || by or
        g = g.replaceAll("\\btrue\\b", "True") // replace true by True
        g = g.replaceAll("\\bfalse\\b", "False") // replace true by False
        g = g.replaceAll("!([^=])", "not $1") // replace negation ! by not
        g = g.replaceAll("(active\\()(.*\\.(.*))(\\))", "$1'$3'$4") // replace for example active(Car.On.r1.Driving) by active('Driving')
        
        return g
    }
	
	/**
	 * Generate the extracted data into this current state
	 * The oncycle, always and every event aren't generated here
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