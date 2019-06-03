package be.ac.umons.bol.generator.sismic.specification

import java.util.ArrayList
import org.eclipse.xtend.lib.annotations.Accessors
import be.ac.umons.bol.generator.sismic.Utils
import java.util.regex.Pattern

/**
 * Français : 
 * Cette classe permet de gérer l'attribut specification contenue dans la balise "outgoingTransitions"
 * 
 * English : 
 * This class manage the specification attribute containing into "outgoingTransitions" tag.
 */
class SpecificationTransition {
	@Accessors String event = ""
	@Accessors String guard = ""
	@Accessors ArrayList<String> listActions;
	
	/**
	 * Constructor
	 * 
	 * @param specification : the string that we must to extract event, guard and actions
	 */
	new(String specification) {
		if (!specification.empty) {
			listActions = new ArrayList
			extractSpecifications(specification)
		}
	}
	
	/**
	 * Constructor
	 * 
	 * @param specification : the string to extract the event and/or the guard
	 * @param actions : the actions to extract and add in the current object
	 */
	new(String specification, String actions) {
		if (!specification.empty) {
			extractSpecifications(specification)
		}
		
		if (!actions.empty) {
			listActions = new ArrayList
			treatActions(actions)
		}
	}
	
	/**
	 * Constructor
	 * It's use only to facilitate the unit test
	 * 
	 * @param event : an event
	 * @param guard : a guard
	 * @param actions : list of actions
	 */
	new(String event, String guard, ArrayList<String> actions) {
		this.event = event
		this.guard = guard
		this.listActions = new ArrayList(actions.size)
		this.listActions.addAll(actions)
	}
	
	/**
	 * check if current SpecificationTransition object has the same event and guard than the SpecificationTransition object in parameter
	 * 
	 * @param specification : the SpecificationTransition object to check the event and guard with the current object
	 * 
	 * @return true, if they have the same trigger (event and guard), false otherwise
	 */
	def haveSameTrigger(SpecificationTransition specification) {
		if (specification === null) {
			return false;
		}
		
		return event.equals(specification.event) && guard.equals(specification.guard)
	}
	
	/**
	 * Add an action into the list of actions
	 */
	def addAction(String action) {
		if (listActions === null) {
			listActions = new ArrayList
		}
		
		treatActions(action)
	}
	
	/**
	 * extract event, guard and actions in the parameter specification
	 * 
	 * @param specification : string to extract the event, guard and actions
	 */
	private def extractSpecifications(String specification) {
		var txt = specification.replaceAll("\\n", " ")
		Utils.searchBinaryOperator(txt)
		
		var indexG = txt.indexOf("[") // search if it exists guard
		var indexA = txt.indexOf("/") // search if it exists action
		
		if (indexA != -1) { // check if it exists an action into the string
			val transitionWithAction = txt.split("/") // create table that contains "event [guard]" as first element and the actions in the second element
			treatActions(transitionWithAction.get(1))
			txt = transitionWithAction.get(0).trim()
		} 
		
		if (indexA != 0) { // if the index isn't the first character in the string
			// then it exists either event, guard or both
			if (indexG != -1) { // then there is a guard
				var firstIndex = txt.indexOf("[")
				var endIndex = txt.indexOf("]", firstIndex)
				val charGuards = newCharArrayOfSize(endIndex - (firstIndex + 1)) // correspond to «new char[endIndex - (firstIndex + 1)]» in Java
				
				txt.getChars(firstIndex + 1, endIndex, charGuards, 0)
				guard = String.valueOf(charGuards)
				treatGuard() // treat the guard to match to a guard for a statechart defined in Sismic
				
				if (indexG != 0) {
					val charEvent = newCharArrayOfSize(firstIndex) // correspond to «new char[firstIndex]» in Java
					
					txt.getChars(0, firstIndex, charEvent, 0)
					
					event = String.valueOf(charEvent).trim()
				}
			} else {
				event = txt
			}
			treatEvent()
		}
	}
	
	/**
	 * extract all actions containing in the string in parameter and treat the actions to suit with the actions defined in Sismic
	 * 
	 * @param action : the string contains one or more actions
	 */
	private def treatActions(String action) {
		var a = action.replaceAll("\\btrue\\b", "True") // replace true by True
        a = a.replaceAll("\\bfalse\\b", "False") // replace false by False
        a = a.replaceAll("raise\\s*(\\w+\\.*\\w*);?", "send(\"$1\")") // convert raise event into send("event")
        a = a.replaceAll("\\bvalueof\\s*\\((\\w+)\\)\\s*", "event.$1") // convert valueof(nameEvent) into event.nameEvent 
        
        if (a.contains(";")) {
            val String[] tabActions = action.split(";")

            for (act : tabActions) {
                listActions.add(act.trim())
            }
        } else {
            listActions.add(a.trim())
        }
	}
	
	/**
	 * Transform the extracted guard into a suitable guard for a statechart defined in Sismic
	 */
	private def treatGuard() {
        guard = guard.replaceAll("(\\s)&&(\\s)", "$1and$2") // replace && by and
        guard = guard.replaceAll("(\\s)\\|\\|(\\s)", "$1or$2") // replace || by or
        guard = guard.replaceAll("\\btrue\\b", "True") // replace true by True
        guard = guard.replaceAll("\\bfalse\\b", "False") // replace true by False
        guard = guard.replaceAll("!([^=])", "not $1") // replace negation ! by not
        guard = guard.replaceAll("(active\\()(.*\\.(.*))(\\))", "$1'$3'$4") // replace (for example) active(Car.On.r1.Driving) by active('Driving')
    }
    
    /**
     * Transform the extracted event into a suitable event for a statechart defined in Sismic
     */
    private def treatEvent() {
    	val regex = "after (\\d+)\\s*(ms|s|m|h)"
    	val p = Pattern.compile(regex)
    	val m = p.matcher(event)
    	
    	if (m.find()) {
    		val eventTime = m.group(0)
    		var double value = Double.valueOf(m.group(1))
    		var timeUnit = m.group(2)
    		
    		switch (timeUnit) {
    			case "ms":
    				value /= 1e3
    			case "us":
    				value /= 1e6
    			case "ns":
    				value /= 1e9
    		}
    		
    		event = event.replaceAll(eventTime, "").trim()
    		var newGuard = "after(" + String.valueOf(value) + ")"
    		
    		if (guard.length == 0) {
    			guard = newGuard
    		} else {
    			guard = guard.concat(" and " + newGuard)
    		}
    	}
    	
    	event = event.replaceAll("\\.", "_")
    	event = event.replaceAll("\\b(always)\\b", "") // always can be replaced by an auto transition
    }
	
	/**
	 * Merge actions list of another instance of SpecificationTransition
	 */
	def mergeSpecification(SpecificationTransition specification) {
		this.listActions.addAll(specification.listActions)
	}
	
	/**
	 * Generate the data extracted in the specification of the outgoingTransition tag
	 */
	def generate() '''
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
	
	override equals(Object obj) {
		if (obj instanceof SpecificationTransition) {
            val temp = obj as SpecificationTransition;

            if (event.equals(temp.getEvent()) && guard.equals(temp.getGuard()) && listActions.size() == temp.listActions.size()) {
                for (var i = 0; i < listActions.size(); i++) {
                    if (!listActions.get(i).equals(temp.listActions.get(i))) {
                        return false;
                    }
                }
                return true;
            }
        }

        return false;
	}
	
	private def actionsToString() '''
		actions :
			«FOR action : listActions»
				- «action»
			«ENDFOR»
	'''
	
	override toString() '''
		event : «event»
		guard : «guard»
		«actionsToString()»
	'''
}