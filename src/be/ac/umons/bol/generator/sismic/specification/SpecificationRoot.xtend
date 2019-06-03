package be.ac.umons.bol.generator.sismic.specification

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.ArrayList
import java.util.regex.Pattern

/**
 * Français :
 * Pour les spécifications dans la balise du statechart (sgraph:Statechart)
 * il faut d'abord diviser la chaine de caractère à chaque fois que 
 * l'on a un retour à la ligne puis chercher toutes les occurences donnant 
 * une fonction et variable.
 * Les commentaires sont ignorés.
 * 
 * Limitation :
 * 	- Le mot-clé "internal" est écarté, il est préférable d'utiliser le mot-clé "interface" dans Yakindu
 * 
 * 
 * English :
 * For the specifications into the sgraph:Statechart tag in XMI
 * It must be split the string for every newline
 * Then we can search every matches given a function or a variable
 * 
 * Limitation :
 * 	- The keyword "internal" is not implemented into this generator, we prefer use the keyword "interface" for the generation
 */
class SpecificationRoot {
	static val REGEX_INTERFACE = "interface\\s?(\\w*)\\s?:"
	static val REGEX_OPERATION = "operation\\s+(.*)\\(((.*)\\s*:\\s*(.*))?\\)\\s*(:\\s*(\\w*))?"
	static val REGEX_VARIABLE = "(var|const)\\s+(.*):\\s*(\\w+)(\\s*=\\s*(.*))?"
	
	@Accessors ArrayList<String> context;
	@Accessors ArrayList<Interface> listInterfaces;
	@Accessors ArrayList<String> variables;
	@Accessors ArrayList<String> operations;
	
	/**
	 * Constructor
	 * 
	 * @param specification : the specification attribute contains in sgraph:Statechart tag
	 * 							this attribute must be extracted to have differents interfaces, 
	 * 							variables and operations to define for the statechart in Sismic.
	 */
	new(String specification) {
		if (!specification.empty) {
			listInterfaces = new ArrayList
			context = new ArrayList
			
			val tabSpec = specification.split("\n")
			
			for (spec : tabSpec) {
				extractSpecification(spec)
			}			
		}
	}
	
	/**
	 * extract variables, operations and/or operations in specification attribute of sgraph:Statechart tag
	 * 
	 * @param specification : the contains of specification attribute
	 */
	private def extractSpecification(String specification) {		
		var p =  Pattern.compile(REGEX_INTERFACE)
		var m = p.matcher(specification)
		
		if (m.find()) {
			val name = m.group(1)
			
			listInterfaces.add(new Interface(name))
			
			if (!name.empty) {
				context.add(name)
			}
		}
		
		p =  Pattern.compile(REGEX_OPERATION)
		m = p.matcher(specification)
		
		if (m.find()) {
			val name = m.group(1)			
			val parameters = m.group(2)
			val typeReturn = m.group(6)
			
			listInterfaces.last.addOperation(name, parameters, typeReturn)
			
			if (listInterfaces.last.isDefaultInterface) {
				context.add(name)
			}
			
			return true
		} else {
			p = Pattern.compile(REGEX_VARIABLE)
			m = p.matcher(specification)
			
			if (m.find()) {
				val StringBuilder varPython = new StringBuilder(50)
				varPython.append(m.group(2) + " = ")
				val type = m.group(3)
				
				if (m.group(5) === null) {
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
					var value = m.group(5)
					
					if (type.equals("boolean")) {
						if (value.contains("true")) {
							value = value.replaceAll("true", "True"); // replace true by True
						} else {
							value = value.replaceAll("false", "False"); // replace false by False
						}
					}
					
					if (value.contains('//')) {
						value = value.replaceAll("//", "#");
					}
					
					varPython.append(value)
				}
				
				listInterfaces.last.addVariable(varPython.toString())
				
				return true
			} else {
				return false
			}
		}
	}
	
	/**
	 * Generate the variables contain in default interface into YAML file
	 */
	def generateYAML() {
		var i = listInterfaces.filter(i | i.name == "").head
		
		if (i === null) {
			return ""
		}
		
		return '''
			«IF i.variables !== null»
				preamble: |
					«FOR variable : i.variables»
						«variable»
					«ENDFOR»
			«ENDIF»
		'''
	}
	
	/**
	 * Generate a class for every named interfaces
	 * For the default interface, generate only the method from this interface
	 */
	def generatePython() '''
		«FOR i : listInterfaces»
			«i.generate»
		«ENDFOR»
	'''
}