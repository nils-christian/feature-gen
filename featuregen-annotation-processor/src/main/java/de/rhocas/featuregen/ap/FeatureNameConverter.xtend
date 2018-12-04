package de.rhocas.featuregen.ap

import org.eclipse.xtend.lib.macro.declaration.AnnotationReference

package class FeatureNameConverter {
	
	def String convertToValidSimpleFeatureName(String rawFeatureName, AnnotationReference annotation) {
		val prefix = annotation.getStringValue('prefix')
		val suffix = annotation.getStringValue('suffix')
		val simpleFeatureName = prefix + rawFeatureName.replaceAll('(\\W)', '') + suffix
		
		simpleFeatureName.toUpperCase
	}
	
}