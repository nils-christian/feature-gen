package de.rhocas.featuregen.ap

import de.rhocas.featuregen.featureide.model.configuration.Configuration
import javax.xml.bind.JAXBContext
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.file.FileSystemSupport
import org.eclipse.xtend.lib.macro.file.Path
import de.rhocas.featuregen.featureide.model.configuration.Feature
import org.eclipse.xtend.lib.macro.declaration.EnumerationTypeDeclaration

class FeatureIDEVariantProcessor extends AbstractClassProcessor {
	
	val extension FeatureNameConverter = new FeatureNameConverter
	val jaxbContext = JAXBContext.newInstance(Configuration)
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) { 
		val annotationReference = annotatedClass.findAnnotation(FeatureIDEVariant.findTypeGlobally)
		val modelFilePath = findModelFilePath(annotatedClass, annotationReference, context)
		val configurationModel = readConfigurationModel(modelFilePath, context)
		val root = getRoot(configurationModel)
		
		val featureEnum = getFeatureEnumName(annotationReference, annotatedClass, root).findTypeGlobally as EnumerationTypeDeclaration
		val features = configurationModel.feature
		val featuresAsEnumValues = features.map[convertToValidSimpleFeatureName(it.name, annotationReference)]
										   .map[it]
										   .map[featureEnum.findDeclaredValue(it)]
		
		val selectedFeaturesAnnotation = getSelectedFeaturesAnnotationName(annotationReference, annotatedClass, root).findTypeGlobally
		annotatedClass.addAnnotation(selectedFeaturesAnnotation.newAnnotationReference [
			setEnumValue('value', featuresAsEnumValues)
		])
	}
	
	private def findModelFilePath(ClassDeclaration annotatedClass, AnnotationReference annotationReference, extension FileLocations context) {
		var value = annotationReference.getStringValue('value')
		if (value == '') {
			value = annotatedClass.simpleName + '.xml'
		}
		
		var Path path
		if (value.startsWith('/')) {
			path = annotatedClass.compilationUnit.filePath.projectFolder
		} else {
			path = annotatedClass.compilationUnit.filePath.parent
		}
		
		return path.append('/').append(value)
	}
	
	private def readConfigurationModel(Path modelFilePath,extension FileSystemSupport fileSystemSupport) {
		val unmarshaller = jaxbContext.createUnmarshaller
		val stream = modelFilePath.contentsAsStream
		try {
			return unmarshaller.unmarshal(stream) as Configuration
		} finally {
			stream.close
		}
	}
	
	private def getRoot(Configuration model) {
		model.feature.head
	}
	
	private def String getSelectedFeaturesAnnotationName(AnnotationReference annotationReference, ClassDeclaration annotatedClass, Feature root) {
		var featuresPackage = getFeaturesPackage(annotationReference, annotatedClass)
		'''«featuresPackage».«root.name»SelectedFeatures'''
	}
		
	private def String getFeatureEnumName(AnnotationReference annotationReference, ClassDeclaration annotatedClass, Feature root) {
		var featuresPackage = getFeaturesPackage(annotationReference, annotatedClass)
		'''«featuresPackage».«root.name»Feature'''
	}
	
	private def getFeaturesPackage(AnnotationReference annotationReference, ClassDeclaration annotatedClass) {
		var featuresPackage = annotationReference.getStringValue('featuresPackage')
		if (featuresPackage.isEmpty) {
			featuresPackage = annotatedClass.compilationUnit.packageName
		}
		
		return featuresPackage
	}
	
}