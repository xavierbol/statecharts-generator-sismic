package be.ac.umons.bol.generator.sismic

import org.yakindu.sct.model.sgen.GeneratorEntry
import org.eclipse.xtext.generator.IFileSystemAccess
import org.yakindu.sct.generator.core.ISGraphGenerator
import org.yakindu.sct.model.sgraph.Statechart
import java.io.FileOutputStream
import java.io.File
import org.yakindu.sct.model.sgraph.Region
import org.yakindu.sct.model.sgraph.Entry
import org.yakindu.sct.model.sgraph.State
import org.yakindu.sct.model.sgraph.Transition

/**
 * Generator to create a statechart for Sismic library in Python
 * Sismic library use YAML file to define a statechart.
 */
class SismicGenerator implements ISGraphGenerator {

	/**
	 * Generate an output file with the generating of Statechart
	 */
	override generate(Statechart sc, GeneratorEntry entry, IFileSystemAccess fsa) {
		fsa.generateFile(sc.name + '.yaml', sc.generate as String)
	}

	/**
	 * Generate a template for statechart object
	 */
	def dispatch String generate(Statechart it) '''
		statechart:
			name: «it.name»
			root state:
				«regions.head.generate»
	'''
	
	/**
	 * Search the name of the first state treated in the current region
	 * 
	 * region : the current region
	 */
	def private String initialState(Region region) {
		region.vertices.filter(Entry).head.outgoingTransitions.head.target.name
	}
	
	/**
	 * Generate an region
	 * This region can be :
	 * 	- The first region of the statechart
	 *  - Other region of the Statechart
	 * 
	 * if it's the first region, it will add name and initial keyword in YAML file
	 */
	def dispatch CharSequence generate(Region it) {
		//var firstState = vertices.filter(State).head

		return '''
			«IF vertices.filter(Entry).head != null»
				name: root
				initial: «initialState»
			«ENDIF»
			states:
				«FOR vertex : vertices.filter(State)»
					«vertex.generate»
				«ENDFOR»
		'''
	}
	
	/**
	 * Generate State of the statechart
	 * In Yakindu, a state is a Vertex with a type State
	 */
	def dispatch CharSequence generate(State it) {
		return '''
			- name: «name»
			  specification: «specification»
			  transitions:
				«FOR transition : outgoingTransitions»
					«transition.generate»
				«ENDFOR»
		'''
	}
	
	/**
	 * Generate Transition of a state
	 */
	def dispatch CharSequence generate(Transition it) {
		return '''
			- target: «target.name»
			  specification: «specification»
		'''
	}

	def write(File dir, String filename, String content) {
		dir.mkdirs
		val bos = new FileOutputStream(new File(dir.path + File::separator + filename))
		bos.write(content.bytes)
		bos.close
	}
}
