////////////////////////////////////////////////////////////////////////////////////
//                                                                                //
// MIT License                                                                    //
//                                                                                //
// Copyright (c) 2018 Nils Christian Ehmke                                        //
//                                                                                //
// Permission is hereby granted, free of charge, to any person obtaining a copy   //
// of this software and associated documentation files (the "Software"), to deal  //
// in the Software without restriction, including without limitation the rights   //
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell      //
// copies of the Software, and to permit persons to whom the Software is          //
// furnished to do so, subject to the following conditions:                       //
//                                                                                //
// The above copyright notice and this permission notice shall be included in all //
// copies or substantial portions of the Software.                                //
//                                                                                //
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR     //
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,       //
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE    //
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER         //
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,  //
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE  //
// SOFTWARE.                                                                      //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

package de.rhocas.featuregen.ap

import de.rhocas.featuregen.featureide.model.configuration.Configuration
import javax.xml.bind.JAXBContext
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.EnumerationTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.file.FileSystemSupport
import org.eclipse.xtend.lib.macro.file.Path

/**
 * This is the annotation processor for {@link FeatureIDEVariant}.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.0.0
 */
final class FeatureIDEVariantProcessor extends AbstractClassProcessor {

	val extension NameProvider = new NameProvider
	val extension FeatureNameConverter = new FeatureNameConverter
	val jaxbContext = JAXBContext.newInstance(Configuration)

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		makeFinal(annotatedClass)
		
		val configurationModel = getConfigurationModel(annotatedClass, context)
		if (configurationModel !== null && featuresAnnotationCanBeFound(annotatedClass, context)) {
			addSelectedFeaturesAnnotation(configurationModel, annotatedClass, context)
			addVariantInterface(configurationModel, annotatedClass, context)
		}
	}
	
	def featuresAnnotationCanBeFound(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val featuresClass = getAnnotatedFeaturesClass(annotatedClass, context) as ClassDeclaration
		val annotationReference = featuresClass.findAnnotation(FeatureIDEFeatures.findTypeGlobally)
		if (annotationReference !== null) {
			return true
		} else {
			annotatedClass.addError('''The referenced class «featuresClass.simpleName» must be annotated with «FeatureIDEFeatures.simpleName».''')
			return false
		}
	}
	
	private def makeFinal(MutableClassDeclaration annotatedClass) {
		annotatedClass.final = true
	}
	
	private def addVariantInterface(Configuration configurationModel, MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val variantInterface = getVariantInterface(configurationModel, annotatedClass, context)
		annotatedClass.implementedInterfaces = #[variantInterface.newSelfTypeReference]
	}
	
	private def getVariantInterface(Configuration configurationModel, MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val fullQualifiedName = getFullQualifiedVariantName(configurationModel, annotatedClass, context)
		fullQualifiedName.findTypeGlobally
	}
	
	private def String getFullQualifiedVariantName(Configuration configurationModel, MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		var annotatedFeaturesClass = getAnnotatedFeaturesClass(annotatedClass, context)
		val root = getRoot(configurationModel)
		getFullQualifiedVariantInterfaceName(annotatedFeaturesClass, root.name)
	}
	
	private def void addSelectedFeaturesAnnotation(Configuration configurationModel, MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val selectedFeaturesAnnotation = getSelectedFeaturesAnnotation(configurationModel, annotatedClass, context)
		annotatedClass.addAnnotation(selectedFeaturesAnnotation.newAnnotationReference [
			setEnumValue('value', getSelectedFeatures(configurationModel, annotatedClass, context))
		])
	}

	private def getSelectedFeaturesAnnotation(Configuration configurationModel, MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val fullQualifiedName = getFullQualifiedSelectedFeaturesAnnotationName(configurationModel, annotatedClass, context)
		fullQualifiedName.findTypeGlobally
	}

	private def String getFullQualifiedSelectedFeaturesAnnotationName(Configuration configurationModel, MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		var annotatedFeaturesClass = getAnnotatedFeaturesClass(annotatedClass, context)
		val root = getRoot(configurationModel)
		getFullQualifiedSelectedFeaturesAnnotationName(annotatedFeaturesClass, root.name)
	}

	private def getAnnotatedFeaturesClass(ClassDeclaration annotatedClass, extension TransformationContext context) {
		val annotationReference = annotatedClass.findAnnotation(FeatureIDEVariant.findTypeGlobally)
		annotationReference.getClassValue('featuresClass').type
	}
	
	private def getRoot(Configuration configurationModel) {
		val features = configurationModel.feature
		features.head
	}

	private def getConfigurationModel(ClassDeclaration annotatedClass, extension TransformationContext context) {
		val modelFilePath = getModelFilePath(annotatedClass, context)
		if (modelFilePath.isFile) {
			readConfigurationModel(modelFilePath, context)
		} else {
			annotatedClass.addError('''The configuration file could not be found (Assumed path was: '«modelFilePath»').''')
		}
	}

	private def getModelFilePath(ClassDeclaration annotatedClass, extension TransformationContext context) {
		val annotationReference = annotatedClass.findAnnotation(FeatureIDEVariant.findTypeGlobally)
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

	private def readConfigurationModel(Path modelFilePath, extension FileSystemSupport fileSystemSupport) {
		val unmarshaller = jaxbContext.createUnmarshaller
		val stream = modelFilePath.contentsAsStream
		try {
			return unmarshaller.unmarshal(stream) as Configuration
		} finally {
			stream.close
		}
	}

	private def getSelectedFeatures(Configuration configurationModel, ClassDeclaration annotatedClass, extension TransformationContext context) {
		val featureEnum = getFeatureEnum(configurationModel, annotatedClass, context)
		val features = configurationModel.feature
		val featuresClass = getAnnotatedFeaturesClass(annotatedClass, context) as ClassDeclaration
		val annotationReference = featuresClass.findAnnotation(FeatureIDEFeatures.findTypeGlobally)
		
		features.map[it.name]
			    .map[convertToValidSimpleFeatureName(it, annotationReference)]
			    .map[featureEnum.findDeclaredValue(it)]
		        .filterNull
	}
	
	private def getFeatureEnum(Configuration configurationModel, ClassDeclaration annotatedClass, extension TransformationContext context) {
		val fullQualifiedName = getFullQualifiedFeatureEnumName(configurationModel, annotatedClass, context)
		fullQualifiedName.findTypeGlobally as EnumerationTypeDeclaration
	}
	
	private def String getFullQualifiedFeatureEnumName(Configuration configurationModel, ClassDeclaration annotatedClass, extension TransformationContext context) {
		var annotatedFeaturesClass = getAnnotatedFeaturesClass(annotatedClass, context)
		val root = getRoot(configurationModel)
		getFullQualifiedFeaturesEnumName(annotatedFeaturesClass, root.name)
	}

}
