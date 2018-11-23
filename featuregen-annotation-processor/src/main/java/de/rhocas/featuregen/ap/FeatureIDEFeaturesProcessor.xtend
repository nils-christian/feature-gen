package de.rhocas.featuregen.ap

import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.file.Path
import javax.xml.bind.JAXBContext
import de.rhocas.featuregen.featureide.model.feature.FeatureModel
import org.eclipse.xtend.lib.macro.file.FileSystemSupport

class FeatureIDEFeaturesProcessor extends AbstractClassProcessor {
	
	val jaxbContext = JAXBContext.newInstance(FeatureModel)
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		val annotationReference = annotatedClass.findAnnotation(FeatureIDEFeatures.findUpstreamType)
		val modelFilePath = findModelFilePath(annotatedClass, annotationReference, context)
		
		if (modelFilePath.isFile) {
			val featureModel = readFeatureModel(modelFilePath, context)
			
			registerFeatureCheckService(featureModel, context)
			registerSelectedFeatures(featureModel, context)
			registerFeature(featureModel, context)
		}
	}
	
	private def findModelFilePath(ClassDeclaration annotatedClass, AnnotationReference annotationReference, extension FileLocations context) {
		var value = annotationReference.getStringValue('value')
		if (value == '') {
			value = 'model.xml'
		}
		
		var Path path
		if (value.startsWith('/')) {
			path = annotatedClass.compilationUnit.filePath.projectFolder
		} else {
			path = annotatedClass.compilationUnit.filePath.parent
		}
		
		return path.append('/').append(value)
	}
	
	private def readFeatureModel(Path modelFilePath, extension FileSystemSupport fileSystemSupport) {
		val unmarshaller = jaxbContext.createUnmarshaller
		val stream = modelFilePath.contentsAsStream
		try {
			return unmarshaller.unmarshal(stream) as FeatureModel
		} finally {
			stream.close
		}
	}
	
	private def registerFeatureCheckService(FeatureModel featureModel, extension RegisterGlobalsContext context) {
		val root = featureModel.struct?.feature
		if (root !== null) {
		}
	}
	
	private def registerSelectedFeatures(FeatureModel featureModel, extension RegisterGlobalsContext context) {
	}
	
	private def registerFeature(FeatureModel featureModel, extension RegisterGlobalsContext context) {
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val annotationReference = annotatedClass.findAnnotation(FeatureIDEFeatures.findTypeGlobally)
		val modelFilePath = findModelFilePath(annotatedClass, annotationReference, context)
		
		if (modelFilePath.isFile) {
			transformFeatureCheckService()
			transformSelectedFeatures()
			transformFeature()
		} else {
			annotatedClass.addError('''The model file could not be found (Assumed path was: '«modelFilePath»').''')
		}
	}
	
	private def transformFeatureCheckService() {
	}
	
	private def transformSelectedFeatures() {
	}
	
	private def transformFeature() {
	}
	
}