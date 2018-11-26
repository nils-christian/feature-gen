package de.rhocas.featuregen.ap

import de.rhocas.featuregen.featureide.model.feature.FeatureModel
import de.rhocas.featuregen.featureide.model.feature.FeatureType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import javax.xml.bind.JAXBContext
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.EnumerationTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.file.FileSystemSupport
import org.eclipse.xtend.lib.macro.file.Path
import java.lang.annotation.Target
import java.lang.annotation.ElementType
import org.eclipse.xtend.lib.macro.declaration.MutableEnumerationTypeDeclaration
import de.rhocas.featuregen.featureide.model.feature.BranchedFeatureType

class FeatureIDEFeaturesProcessor extends AbstractClassProcessor {
	
	val extension FeatureNameConverter = new FeatureNameConverter
	val jaxbContext = JAXBContext.newInstance(FeatureModel)
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, extension RegisterGlobalsContext context) {
		val annotationReference = annotatedClass.findAnnotation(FeatureIDEFeatures.findUpstreamType)
		val modelFilePath = findModelFilePath(annotatedClass, annotationReference, context)
		
		if (modelFilePath.isFile) {
			val featureModel = readFeatureModel(modelFilePath, context)
			
			registerFeatureCheckService(annotatedClass, featureModel, context)
			registerSelectedFeatures(annotatedClass, featureModel, context)
			registerFeature(annotatedClass, featureModel, context)
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
	
	private def registerFeatureCheckService(ClassDeclaration annotatedClass, FeatureModel featureModel, extension RegisterGlobalsContext context) {
		val root = featureModel.getRoot()
		if (root !== null) {
			registerClass(getFeatureCheckServiceName(annotatedClass, root))
		}
	}
	
	private def String getFeatureCheckServiceName(ClassDeclaration annotatedClass, FeatureType root) {
		'''«annotatedClass.compilationUnit.packageName».«root.name»FeatureCheckService'''
	}
	
	
	private def getRoot(FeatureModel model) {
		val struct = model.struct
		
		if (struct.feature !== null) {
			struct.feature
		} else if (struct.and !== null) {
			struct.and
		} else if (struct.or !== null) {
			struct.or
		} else {
			struct.alt
		}
	}
	
	private def registerSelectedFeatures(ClassDeclaration annotatedClass, FeatureModel featureModel, extension RegisterGlobalsContext context) {
		val root = featureModel.getRoot()
		if (root !== null) {
			registerAnnotationType(getSelectedFeatureAnnotationName(annotatedClass, root))
		}
	}
	
	private def String getSelectedFeatureAnnotationName(ClassDeclaration annotatedClass, FeatureType root)
		'''«annotatedClass.compilationUnit.packageName».«root.name»SelectedFeatures'''
	
	
	private def registerFeature(ClassDeclaration annotatedClass, FeatureModel featureModel, extension RegisterGlobalsContext context) {
		val root = featureModel.getRoot()
		if (root !== null) {
			registerEnumerationType(getFeatureEnumName(annotatedClass, root))
		}
	} 
	
	private def String getFeatureEnumName(ClassDeclaration annotatedClass, FeatureType root) {
		'''«annotatedClass.compilationUnit.packageName».«root.name»Feature'''
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val annotationReference = annotatedClass.findAnnotation(FeatureIDEFeatures.findTypeGlobally)
		val modelFilePath = findModelFilePath(annotatedClass, annotationReference, context)
		
		if (modelFilePath.isFile) {
			val featureModel = readFeatureModel(modelFilePath, context)
			
			transformFeatureCheckService(annotatedClass, featureModel, context)
			transformSelectedFeatures(annotatedClass, featureModel, context)
			transformFeature(annotatedClass, featureModel, context)
		} else {
			annotatedClass.addError('''The model file could not be found (Assumed path was: '«modelFilePath»').''')
		}
	}
	
	private def transformFeatureCheckService(MutableClassDeclaration annotatedClass, FeatureModel featureModel, extension TransformationContext context) {
		val root = featureModel.getRoot()
		val featureCheckService = getFeatureCheckServiceName(annotatedClass, root).findClass
		
		featureCheckService.addMethod('isFeatureActive') [
			addParameter('feature', getFeatureEnumName(annotatedClass, root).newTypeReference())
			returnType = primitiveBoolean
			
			body = '''
				return false;
			'''
		]
	}
	
	private def transformSelectedFeatures(MutableClassDeclaration annotatedClass, FeatureModel featureModel, extension TransformationContext context) {
		val root = featureModel.getRoot()
		val selectedFeatures = getSelectedFeatureAnnotationName(annotatedClass, root).findAnnotationType

		selectedFeatures.addAnnotation(Retention.newAnnotationReference [
			setEnumValue('value', (RetentionPolicy.findTypeGlobally as EnumerationTypeDeclaration).findDeclaredValue(RetentionPolicy.RUNTIME.name))
		])
		selectedFeatures.addAnnotation(Target.newAnnotationReference [
			setEnumValue('value', (ElementType.findTypeGlobally as EnumerationTypeDeclaration).findDeclaredValue(ElementType.TYPE.name))
		])
		
		selectedFeatures.addAnnotationTypeElement('value') [ 
			type = getFeatureEnumName(annotatedClass, root).findEnumerationType.newSelfTypeReference.newArrayTypeReference
		]
	}
	
	private def transformFeature(MutableClassDeclaration annotatedClass, FeatureModel featureModel, extension TransformationContext context) {
		val root = featureModel.getRoot()
		val feature = getFeatureEnumName(annotatedClass, root).findEnumerationType
		val annotation = annotatedClass.findAnnotation(FeatureIDEFeatures.findTypeGlobally)
		
		addFeaturesToEnum(feature, annotation, root)
	}
	
	private def void addFeaturesToEnum(MutableEnumerationTypeDeclaration enumeration, AnnotationReference annotationReference, FeatureType type) {
		if (type !== null) {
			enumeration.addValue(type.name.convertToValidSimpleFeatureName(annotationReference)) []
			
			if (type instanceof BranchedFeatureType) {
				for (feature : type.andOrOrOrAlt) {
					addFeaturesToEnum(enumeration, annotationReference, feature.value)
				}
			}
		}
	}
	
}