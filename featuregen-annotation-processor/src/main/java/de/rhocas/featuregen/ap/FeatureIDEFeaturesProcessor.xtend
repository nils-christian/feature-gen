package de.rhocas.featuregen.ap

import de.rhocas.featuregen.featureide.model.feature.BranchedFeatureType
import de.rhocas.featuregen.featureide.model.feature.FeatureModel
import de.rhocas.featuregen.featureide.model.feature.FeatureType
import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import java.util.EnumSet
import java.util.Objects
import javax.xml.bind.JAXBContext
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationReference
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.EnumerationTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableEnumerationTypeDeclaration
import org.eclipse.xtend.lib.macro.file.FileLocations
import org.eclipse.xtend.lib.macro.file.FileSystemSupport
import org.eclipse.xtend.lib.macro.file.Path
import java.util.List
import java.util.Arrays
import java.util.Collections
import java.util.Set

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
			registerVariant(annotatedClass, featureModel, context)
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
			registerAnnotationType(getSelectedFeaturesAnnotationName(annotatedClass, root))
		}
	}
	
	private def String getSelectedFeaturesAnnotationName(ClassDeclaration annotatedClass, FeatureType root)
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
	
	private def registerVariant(ClassDeclaration annotatedClass, FeatureModel featureModel, extension RegisterGlobalsContext context) {
		val root = featureModel.getRoot()
		if (root !== null) {
			registerInterface(getVariantName(annotatedClass, root))
		}
	}
	
	private def String getVariantName(ClassDeclaration annotatedClass, FeatureType root) {
		'''«annotatedClass.compilationUnit.packageName».«root.name»Variant'''
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val annotationReference = annotatedClass.findAnnotation(FeatureIDEFeatures.findTypeGlobally)
		val modelFilePath = findModelFilePath(annotatedClass, annotationReference, context)
		
		if (modelFilePath.isFile) {
			val featureModel = readFeatureModel(modelFilePath, context)
			
			transformFeatureCheckService(annotatedClass, featureModel, context)
			transformSelectedFeatures(annotatedClass, featureModel, context)
			transformFeature(annotatedClass, featureModel, context)
			transformVariant(annotatedClass, featureModel, context)
		} else {
			annotatedClass.addError('''The model file could not be found (Assumed path was: '«modelFilePath»').''')
		}
	}
	
	private def transformFeatureCheckService(MutableClassDeclaration annotatedClass, FeatureModel featureModel, extension TransformationContext context) {
		val root = featureModel.getRoot()
		val featureCheckService = getFeatureCheckServiceName(annotatedClass, root).findClass
		val featureEnum = getFeatureEnumName(annotatedClass, root).findEnumerationType

		featureCheckService.final = true
		featureCheckService.docComment = '''
		This service allows to set the currently active variant and to check which features are currently active.<br/>
		<br/>
		Note that this class is conditionally thread safe. This means that it is possible to concurrently set the 
		variant and check the features, but it is possible that a check for a feature returns {@code false} between
		the switching from one variant to another even if both variants contain said feature. Add additional
		synchronization if switching the variant must be an atomic operation.<br/>
		<br/>
		This service is generated.
		'''

		featureCheckService.addField('activeFeatures') [
			final = true
			type = Set.newTypeReference
			initializer = '''«Collections.newTypeReference()».synchronizedSet( «EnumSet.newTypeReference».noneOf( «featureEnum.newTypeReference».class ) )'''
		]

		featureCheckService.addMethod('isFeatureActive') [
			docComment = '''
				Checks whether the given feature is currently active or not.
				
				@param feature
					The feature to check. Must not be {@code null}.
					
				@return true if and only if the given feature is active.
				
				@throws NullPointerException
					If the given feature is {@code null}.
			'''
			
			addParameter('feature', getFeatureEnumName(annotatedClass, root).newTypeReference())
			returnType = primitiveBoolean
			
			body = '''
				«Objects.newTypeReference».requireNonNull( feature, "The feature must not be null." );
				
				return activeFeatures.contains( feature );
			'''
		]
		
		val variant = getVariantName(annotatedClass, root).findInterface
		val selectedFeaturesAnnotation = getSelectedFeaturesAnnotationName(annotatedClass, root).findAnnotationType
		featureCheckService.addMethod('setActiveVariant') [
			docComment = '''
				Sets the currently active variant.
				
				@param variant
					The new variant. Must not be {@code null} and must be annotated with {@link «selectedFeaturesAnnotation.newTypeReference()»}.
					
				@throws NullPointerException
					If the given variant is {@code null} or not annotated with {@link «selectedFeaturesAnnotation.newTypeReference()»}.
			'''
			
			addParameter('variant', Class.newTypeReference(newWildcardTypeReference(variant.newSelfTypeReference)))
			
			body = '''
				«Objects.newTypeReference».requireNonNull( variant, "The variant must not be null." );
				
				final «selectedFeaturesAnnotation.newTypeReference» selectedFeaturesAnnotation = variant.getAnnotation( «selectedFeaturesAnnotation.newTypeReference».class );
				«Objects.newTypeReference()».requireNonNull( selectedFeaturesAnnotation, "The variant must be annotated with «selectedFeaturesAnnotation.simpleName»." );
				final «List.newTypeReference(featureEnum.newSelfTypeReference)» selectedFeatures = «Arrays.newTypeReference()».asList( selectedFeaturesAnnotation.value( ) );
				
				activeFeatures.clear( );
				activeFeatures.addAll( selectedFeatures );
			'''
		]
	}
	
	private def transformSelectedFeatures(MutableClassDeclaration annotatedClass, FeatureModel featureModel, extension TransformationContext context) {
		val root = featureModel.getRoot()
		val selectedFeatures = getSelectedFeaturesAnnotationName(annotatedClass, root).findAnnotationType

		selectedFeatures.docComment = '''
		This annotation is used to mark which features the annotated variant provides.<br/>
		<br/>
		This annotation is generated.
		'''

		selectedFeatures.addAnnotation(Retention.newAnnotationReference [
			setEnumValue('value', (RetentionPolicy.findTypeGlobally as EnumerationTypeDeclaration).findDeclaredValue(RetentionPolicy.RUNTIME.name))
		])
		selectedFeatures.addAnnotation(Target.newAnnotationReference [
			setEnumValue('value', (ElementType.findTypeGlobally as EnumerationTypeDeclaration).findDeclaredValue(ElementType.TYPE.name))
		])
		
		selectedFeatures.addAnnotationTypeElement('value') [ 
			docComment = 'The selected features.'		
				
			type = getFeatureEnumName(annotatedClass, root).findEnumerationType.newSelfTypeReference.newArrayTypeReference
		]
	}
	
	private def transformFeature(MutableClassDeclaration annotatedClass, FeatureModel featureModel, extension TransformationContext context) {
		val root = featureModel.getRoot()
		val feature = getFeatureEnumName(annotatedClass, root).findEnumerationType
		val annotation = annotatedClass.findAnnotation(FeatureIDEFeatures.findTypeGlobally)
		
		feature.docComment = '''
		This enumeration contains all available features.<br/>
		<br/>
		This enumeration is generated.
		'''
		
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
	
		
	private def transformVariant(MutableClassDeclaration annotatedClass, FeatureModel featureModel, extension TransformationContext context) {
		val root = featureModel.getRoot()
		val variant = getVariantName(annotatedClass, root).findInterface
		variant.docComment = '''
		This is a marker interface for all variants.<br/>
		<br/>
		This interface is generated.
		'''
	}
	
}