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

package de.rhocas.featuregen.generator

import de.rhocas.featuregen.featureide.model.feature.BranchedFeatureType
import de.rhocas.featuregen.featureide.model.feature.FeatureModel
import de.rhocas.featuregen.featureide.model.feature.FeatureModelType
import de.rhocas.featuregen.featureide.model.feature.FeatureType
import java.io.File
import java.lang.annotation.ElementType
import java.lang.annotation.Retention
import java.lang.annotation.RetentionPolicy
import java.lang.annotation.Target
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.util.ArrayList
import java.util.Arrays
import java.util.EnumSet
import java.util.List
import java.util.Objects
import java.util.Set
import javax.xml.bind.JAXBContext
import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Collections

/**
 * This class generates the features from a FeatureIDE model file.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
final class FeatureIDEFeaturesGenerator {

	/**
	 * The main entry point of the standalone generator.
	 * 
	 * @param args
	 * 		The command line arguments. See {@link #generate(String[])} for details.
	 * 
	 * @since 1.1.0
	 */
	def static void main(String[] args) {
		val generator = new FeatureIDEFeaturesGenerator()
		generator.generate(args)
	}

	/**
	 * This method performs the actual generation.
	 * 
	 * @param args
	 * 		The arguments for the generator. This array must contain at least three entries. The arguments are as following:
	 *      <ul>
	 *      	<li>The path to the FeatureIDE feature model file.</li>
	 *          <li>The path to the output folder.</li>
	 *          <li>The package name of the newly generated classes.</li>
	 *          <li>The optional prefix prepended to each feature.</li>
	 *          <li>The optional suffix appended to each feature. If this parameter is not given, {@code _FEATURE} will be used instead.</li>
	 *      </ul>
	 * 
	 * @throws IllegalArgumentException
	 * 		If the number of arguments is invalid or if the model file can not be found.		
	 * 
	 * @since 1.1.0
	 */
	def void generate(String[] args) {
		val parameters = convertAndCheckParameters(args)
		
		generateVariantInterface(parameters)
		generateFeatureEnumeration(parameters)
		generateSelectedFeaturesAnnotation(parameters)
		generateFeatureCheckServiceClass(parameters)
	}
	
	private def Parameters convertAndCheckParameters(String[] args) {
		if (args.size < 3) {
			throw new IllegalArgumentException('''Invalid number of arguments. Expected 3, but was «args.size».''')
		}

		val modelFilePath = args.get(0)
		val modelFile = new File(modelFilePath)
		if (!modelFile.isFile) {
			throw new IllegalArgumentException('''Model file "«modelFilePath»" can not be found.''')
		}
		val featureModel = readFeatureModel(modelFile)
		
		val outputFolderPath = args.get(1)
		val outputFolder = new File(outputFolderPath)
		
		val packageName = args.get(2)
		
		val prefix = 
			if (args.size >= 4) {
				args.get(3)
			} else {
				''
			}
			
		val suffix = 
			if (args.size >= 5) {
				args.get(4)
			} else {
				'_FEATURE'
			}
			
		new Parameters(featureModel, packageName, outputFolder, prefix, suffix)
	}
	
	private def FeatureModelType readFeatureModel(File modelFile) {
		val jaxbContext = JAXBContext.newInstance(FeatureModel)
		val unmarshaller = jaxbContext.createUnmarshaller
		return unmarshaller.unmarshal(modelFile) as FeatureModelType
	}
	
	private def void generateVariantInterface(Parameters parameters) {
		val extension nameProvider = new NameProvider
		val rootName = parameters.featureModel.root.name
		
		val simpleName = getSimpleVariantInterfaceName(rootName)
		val outputFile = prepareOutputFile(parameters, simpleName)
		Files.write(outputFile.toPath, '''
			package «parameters.packageName»;
			
			/**
			 * This is a marker interface for all variants.<br>
			 * <br>
			 * This interface is generated.
			 */
			public interface «simpleName» {
				
			}
		'''.toString.getBytes(StandardCharsets.UTF_8))
	}
	
	private def File prepareOutputFile(Parameters parameters, String elementName) {
		val packagePath = parameters.packageName.replace('.', '/')
		val outputFileParent = new File(parameters.outputFolder, packagePath)
		outputFileParent.mkdirs
	
		new File(outputFileParent, '''«elementName».java''')
	}

	private def FeatureType getRoot(FeatureModelType model) {
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
	
	private def generateFeatureEnumeration(Parameters parameters) {
		val extension nameProvider = new NameProvider
		val extension featureNameConverter = new FeatureNameConverter
		
		val root = parameters.featureModel.root
		val rootName = root.name
		
		val simpleName = getSimpleFeaturesEnumName(rootName)
		val outputFile = prepareOutputFile(parameters, simpleName)
		Files.write(outputFile.toPath, '''
			package «parameters.packageName»;
			
			/**
			 * This enumeration contains all available features.<br>
			 * <br>
			 * This enumeration is generated.
			 */
			public enum «simpleName» {
				
				«FOR feature : linearizeFeatures(root) SEPARATOR ','»
					«IF !feature.description.nullOrEmpty»
					/**
					 * «feature.description»
					 */
					«ENDIF»
					«feature.name.convertToValidSimpleFeatureName(parameters.prefix, parameters.suffix)»
				«ENDFOR»
			}
		'''.toString.getBytes(StandardCharsets.UTF_8))
	}
	
	private def List<FeatureType> linearizeFeatures(FeatureType type) {
		val List<FeatureType> features = new ArrayList
		
		if (type !== null) {
			if (!Boolean.TRUE.equals(type.abstract)) {
				features += type
			}
			
			if (type instanceof BranchedFeatureType) {
				for (feature : type.andOrOrOrAlt) {
					features += linearizeFeatures(feature.value)
				}
			}
		}
		
		features
	}
	
	private def generateSelectedFeaturesAnnotation(Parameters parameters) {
		val extension nameProvider = new NameProvider
		
		val rootName = parameters.featureModel.root.name
		
		val simpleName = getSimpleSelectedFeaturesAnnotationName(rootName)
		val outputFile = prepareOutputFile(parameters, simpleName)
		Files.write(outputFile.toPath, '''
			package «parameters.packageName»;
			
			import «Retention.name»;
			import «RetentionPolicy.name»;
			import «Target.name»;
			import «ElementType.name»;
			
			/**
			 * This annotation is used to mark which features the annotated variant provides.<br>
			 * <br>
			 * This annotation is generated.
			 */
			@«Retention.simpleName»( «RetentionPolicy.simpleName».«RetentionPolicy.RUNTIME.name» )
			@«Target.simpleName»( «ElementType.simpleName».«ElementType.TYPE.name» )
			public @interface «simpleName» {
				
				/**
				 * The selected features.
				 */
				«getSimpleFeaturesEnumName(rootName)»[] value( );
				
			}
		'''.toString.getBytes(StandardCharsets.UTF_8))
	}
	
	private def generateFeatureCheckServiceClass(Parameters parameters) {
		val extension nameProvider = new NameProvider
		
		val rootName = parameters.featureModel.root.name
		
		val simpleName = getSimpleFeatureCheckServiceClassName(rootName)
		val simpleSelectedFeaturesAnnotationName = getSimpleSelectedFeaturesAnnotationName(rootName)
		val simpleFeaturesEnumName = getSimpleFeaturesEnumName(rootName)
		
		val outputFile = prepareOutputFile(parameters, simpleName)
		Files.write(outputFile.toPath, '''
			package «parameters.packageName»;
			
			import «Set.name»;
			import «EnumSet.name»;
			import «Objects.name»;
			import «List.name»;
			import «Arrays.name»;
			import «Collections.name»;
			
			/**
			 * This service allows to check which features are currently active.<br>
			 * <br>
			 * Note that instances of this class are immutable and thus inherent thread safe.<br>
			 * <br>
			 * This service is generated.
			 */
			public final class «simpleName» {
				
				private final «Set.simpleName»<«simpleFeaturesEnumName»> activeFeatures;
				private final String description;
				
				private «simpleName»( final «List.simpleName»<«simpleFeaturesEnumName»> selectedFeatures, final String variantName ) {
					activeFeatures = «EnumSet.simpleName».noneOf( «simpleFeaturesEnumName».class );
					activeFeatures.addAll( selectedFeatures );
					
					description = "«simpleName» [" + variantName + "]";
				}
				
				/**
				 * Checks whether the given feature is currently active or not.
				 *
				 * @param feature
				 * 		The feature to check. Must not be {@code null}.
				 * 
				 * @return true if and only if the given feature is active.
				 * 
				 * @throws NullPointerException
				 *		If the given feature is {@code null}.
				 */
				public boolean isFeatureActive( final «simpleFeaturesEnumName» feature ) {
					«Objects.simpleName».requireNonNull( feature, "The feature must not be null." );
					
					return activeFeatures.contains( feature );
				}
				
				@«Override.simpleName»
				public String toString( ) {
					return description;
				}
				
				/**
				 * Creates a new instance of this service with the features of the given variant.
				 *
				 * @param variant
				 *		The new variant. Must not be {@code null} and must be annotated with {@link «simpleSelectedFeaturesAnnotationName»}.
				 *
				 * @return A new feature check service.
				 * 
				 * @throws NullPointerException
				 *		If the given variant is {@code null} or not annotated with {@link «simpleSelectedFeaturesAnnotationName»}.
				 */
				public static «simpleName» of( final Class<? extends «getSimpleVariantInterfaceName(rootName)»> variant ) {
					«Objects.simpleName».requireNonNull( variant, "The variant must not be null." );
					
					final «simpleSelectedFeaturesAnnotationName» selectedFeaturesAnnotation = variant.getAnnotation( «simpleSelectedFeaturesAnnotationName».class );
					«Objects.simpleName».requireNonNull( selectedFeaturesAnnotation, "The variant must be annotated with «simpleSelectedFeaturesAnnotationName»." );
					final «List.simpleName»<«simpleFeaturesEnumName»> selectedFeatures = «Arrays.simpleName».asList( selectedFeaturesAnnotation.value( ) );
				
					return new «simpleName»( selectedFeatures, variant.getSimpleName( ) );
				}
				
				/**
				 * Creates a new instance of this service without any active features.
				 *
				 * @return A new feature check service.
				 */	
				public static «simpleName» empty( ) {
					return new «simpleName»( «Collections.simpleName».emptyList( ), "Empty" );
				}
				
			}
		'''.toString.getBytes(StandardCharsets.UTF_8))
	}
	
	@Accessors
	private static final class Parameters {
		
		val FeatureModelType featureModel
		val String packageName
		val File outputFolder
		val String prefix
		val String suffix
		
	}

}
