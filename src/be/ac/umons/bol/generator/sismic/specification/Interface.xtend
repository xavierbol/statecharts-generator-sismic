package be.ac.umons.bol.generator.sismic.specification

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.ArrayList
import be.ac.umons.bol.generator.sismic.Utils

class Interface {
	@Accessors String name = ""
	@Accessors ArrayList<String> variables;
	@Accessors ArrayList<String> operations;
	
	/**
	 * Default constructor
	 */
	new() {
		variables = new ArrayList
		operations = new ArrayList
	}
	
	/**
	 * Constructor
	 * 
	 * @param name : the name of the interface
	 */
	new(String name) {
		this()
		this.name = name
	}
	
	/**
	 * @return 	- 	true, if this object is the default interface in Statechart
	 * 			-	false, otherwise
	 */
	def isDefaultInterface() {
		return name.empty
	}
	
	/**
	 * Add new variable
	 * 
	 * @param variable the extracted variable in SpecificationRoot
	 */
	def addVariable(String variable) {
		variables.add(variable)
	}
	
	/**
	 * Add new operation
	 */
	def addOperation(String name, String parameters, String typeReturn) {
		var StringBuilder funcPython = new StringBuilder("def " + name + "(")
		
		// Add self in the operation if the interface is not the default
		// because we generate a class for the named interfaces
		if (!isDefaultInterface) {
			funcPython.append("self")
		}
			
		// If it exists some parameters into the operations
		if (parameters !== null && !parameters.empty) {
			// If the interface is not the default add a coma to add parameters in the function
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
	
	/**
	 * Check if the current interface contains the variable
	 * 
	 * @param variable : the variable to search
	 * 
	 * @return boolean : true if this variable is found, false otherwise
	 */
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