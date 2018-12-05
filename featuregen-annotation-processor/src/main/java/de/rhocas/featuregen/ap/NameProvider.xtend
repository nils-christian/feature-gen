package de.rhocas.featuregen.ap

import org.eclipse.xtend.lib.macro.declaration.Type

package class NameProvider {

	def String getFullQualifiedFeaturesEnumName(Type annotatedElement, String rootFeatureName) {
		'''«getFullQualifiedPrefix(annotatedElement, rootFeatureName)»Feature'''
	}

	def String getFullQualifiedFeatureCheckServiceClassName(Type annotatedElement, String rootFeatureName) {
		'''«getFullQualifiedPrefix(annotatedElement, rootFeatureName)»FeatureCheckService'''
	}

	def String getFullQualifiedSelectedFeaturesAnnotationName(Type annotatedElement, String rootFeatureName) {
		'''«getFullQualifiedPrefix(annotatedElement, rootFeatureName)»SelectedFeatures'''
	}

	def String getFullQualifiedVariantInterfaceName(Type annotatedElement, String rootFeatureName) {
		'''«getFullQualifiedPrefix(annotatedElement, rootFeatureName)»Variant'''
	}

	private def String getFullQualifiedPrefix(Type annotatedElement, String rootFeatureName) {
		// We cannot use the package of the compilation unit as this leads to wrong results in this case.
		val qualifiedName = annotatedElement.qualifiedName
		val simpleName = annotatedElement.simpleName
		val packageName = qualifiedName.substring(0, qualifiedName.length - simpleName.length - 1)
		
		'''«packageName».«rootFeatureName»'''
	}

}
