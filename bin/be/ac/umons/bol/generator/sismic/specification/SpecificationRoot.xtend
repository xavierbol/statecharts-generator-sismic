package be.ac.umons.bol.generator.sismic.specification

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.ArrayList
import java.util.regex.Pattern
import be.ac.umons.bol.generator.sismic.Utils

/**
 * Pour les spécifications dans la balise du statechart (sgraph:Statechart)
 * il faut d'abord diviser la chaine de caractère à chaque fois que 
 * l'on a un retour à la ligne puis chercher toutes les occurences donnant 
 * une fonction et variable.
 * Les commentaires sont ignorés.
 * 
 * TODO: extract many interfaces
 */
class SpecificationRoot {
	static val REGEX_INTERFACE = ""
	static val REGEX_OPERATION = "operation\\s+(.*)\\(((.*)\\s*:\\s*(.*))?\\)\\s*:\\s*(\\w*)"
	static val REGEX_VARIABLE = "var\\s+(.*):\\s*(\\w+)(\\s*=\\s*(.*))?"
	
	@Accessors ArrayList<String> context;
	@Accessors String nameInterface;
	@Accessors ArrayList<String> variables;
	@Accessors ArrayList<String> operations;
	
	new(String specification) {
		if (!specification.empty) {
			val tabSpec = specification.split("\n")
			
			for (spec : tabSpec) {
				extractSpecification(spec)
			}			
		}
	}
	
	private def extractSpecification(String specification) {
		var p =  Pattern.compile(REGEX_OPERATION)
		var m = p.matcher(specification)
		
		if (m.find()) {
			val name = m.group(1)			
			val parameters = m.group(2)
			val typeReturn = m.group(5)
			
			var StringBuilder funcPython = new StringBuilder("def " + name + "(")
			
			if (parameters !== null) {
				val tabParameters = parameters.split(",")
				
				for (var i = 0; i < tabParameters.length; i++) {
					val param = tabParameters.get(i).split(":")
					val nameParam = param.get(0).trim()
					var typeParam = param.get(1).trim()
					
					funcPython.append(nameParam + ": " + Utils.translateTypeInPythonType(typeParam))
					
					// Vérifie si ce n'est pas le dernier paramètre de la fonction
					if (i < tabParameters.length - 1) { 
						funcPython.append(", ") 					
					}
				}
			}
			
			funcPython.append(") -> " + Utils.translateTypeInPythonType(typeReturn) + ":") 
			
			if (operations === null) {
				operations = new ArrayList
				context = new ArrayList
			}
			
			operations.add(funcPython.toString())
			context.add(name)
			
			return true
		} else {
			p = Pattern.compile(REGEX_VARIABLE)
			m = p.matcher(specification)
			
			if (m.find()) {
				val StringBuilder varPython = new StringBuilder(50)
				varPython.append(m.group(1) + " = ")
				val type = m.group(2)
				
				if (m.group(4) === null) {
					if (type.equals("integer")) {
						varPython.append("0");
					} else if (type.equals("float") || type.equals("real")) {
						varPython.append("0.0");
					} else if (type.equals("String")) {
						varPython.append("\"\"")
					} else if (type.equals("boolean")) {
						varPython.append("False")
					}
				} else {
					var value = m.group(4)
					
					if (type.equals("boolean")) {
						if (value.contains("true")) {
							value = value.replaceAll("true", "True"); // replace true by True
						} else {
							value = value.replaceAll("false", "False"); // replace false by False
						}
					}
					
					varPython.append(value)
				}
				
				if (variables === null) {
					variables = new ArrayList
				}
				
				variables.add(varPython.toString())
				
				return true
			} else {
				return false
			}
		}
	}
	
	def generateYAML() '''
		«IF variables !== null»
			preamble: |
				«FOR variable : variables»
					«variable»
				«ENDFOR»
		«ENDIF»
	'''
	
	def generatePython() '''
		«IF operations !== null»
			«FOR function : operations»
				«function»
					...
			«ENDFOR»
		«ENDIF»
	'''
}