package be.ac.umons.bol.generator.sismic.specification

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.ArrayList
import be.ac.umons.bol.generator.sismic.Utils

class Interface {
	@Accessors String name = ""
	@Accessors ArrayList<String> variables;
	@Accessors ArrayList<String> operations;
	
	new() {
		variables = new ArrayList
		operations = new ArrayList
	}
	
	new(String name) {
		this()
		this.name = name
	}
	
	/**
	 * Return true if this object is the default interface in Statechart
	 * and false otherwise
	 */
	def isDefaultInterface() {
		return name.empty
	}
	
	/**
	 * Add new variable
	 */
	def addVariable(String variable) {
		variables.add(variable)
	}
	
	/**
	 * Add new operation
	 */
	def addOperation(String name, String parameters, String typeReturn) {
		var StringBuilder funcPython = new StringBuilder("def " + name + "(")
		
		if (!isDefaultInterface) {
			funcPython.append("self")
		}
			
		if (parameters !== null) {
			if (!isDefaultInterface) {
				funcPython.append(", ")
			}			
			
			val tabParameters = parameters.split(",")
			
			for (var i = 0; i < tabParameters.length; i++) {
				val param = tabParameters.get(i).split(":")
				val nameParam = param.get(0).trim()
				var typeParam = param.get(1).trim()
				
				funcPython.append(nameParam + ": " + Utils.translateTypeInPythonType(typeParam))
				
				// Check if isn't the last parameter of operation
				if (i < tabParameters.length - 1) { 
					funcPython.append(", ") 					
				}
			}
		}
		
		funcPython.append(") -> " + Utils.translateTypeInPythonType(typeReturn) + ":")
		
		if (operations === null) {
			operations = new ArrayList
		}
		
		operations.add(funcPython.toString())
	}
	
	def containsVariable(String variable) {
		return variables.filter(name | name.equals(variable)).head !== null
	}
	
	/**
	 * Generate this Interface object into a Python file
	 * If the interface is named, then create a class
	 * else generate only the operations
	 */
	def generate() '''
		«IF !name.empty»
			class «name»:
				«FOR variable : variables»
					self.«variable»
				«ENDFOR»
				
				«FOR method : operations»
					«method»
						...
				«ENDFOR»
			
			
		«ELSE»
			«FOR method : operations»
				«method»
					...
				
				
			«ENDFOR»
		«ENDIF»
	'''
}