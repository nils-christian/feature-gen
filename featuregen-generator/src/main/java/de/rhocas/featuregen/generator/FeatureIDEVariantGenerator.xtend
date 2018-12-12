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

import de.rhocas.featuregen.featureide.model.configuration.Configuration
import java.io.File
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import javax.xml.bind.JAXBContext
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * This class generates the variant from a FeatureIDE configuration file.
 * 
 * @author Nils Christian Ehmke
 * 
 * @since 1.1.0
 */
final class FeatureIDEVariantGenerator {
	
	/**
	 * The main entry point of the standalone generator.
	 * 
	 * @param args
	 * 		The command line arguments. See {@link #generate(String[])} for details.
	 * 
	 * @since 1.1.0
	 */
	def static void main(String[] args) {
		val generator = new FeatureIDEVariantGenerator()
		generator.generate(args)
	}

	/**
	 * This method performs the actual generation.
	 * 
	 * @param args
	 * 		The arguments for the generator. This array must contain at least three entries. The arguments are as following:
	 *      <ul>
	 *      	<li>The path to the FeatureIDE configuration model file.</li>
	 *          <li>The path to the output folder.</li>
	 *          <li>The package name for the newly generated variant.</li>
	 *          <li>The simple class name of the new variant.</li>
	 *          <li>The package name of the features.</li>
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
		
		generateVariantClass(parameters)
	}
	
	private def Parameters convertAndCheckParameters(String[] args) {
		if (args.size < 5) {
			throw new IllegalArgumentException('''Invalid number of arguments. Expected 5, but was «args.size».''')
		}

		val modelFilePath = args.get(0)
		val modelFile = new File(modelFilePath)
		if (!modelFile.isFile) {
			throw new IllegalArgumentException('''Model file "«modelFilePath»" can not be found.''')
		}
		val configurationModel = readConfigurationModel(modelFile)
		
		val outputFolderPath = args.get(1)
		val outputFolder = new File(outputFolderPath)
		
		val packageName = args.get(2)
		val className = args.get(3)
		val featuresPackageName = args.get(4)
		
		val prefix = 
			if (args.size >= 6) {
				args.get(5)
			} else {
				''
			}
			
		val suffix = 
			if (args.size >= 7) {
				args.get(6)
			} else {
				'_FEATURE'
			}
			
		new Parameters(configurationModel, packageName, className, outputFolder, featuresPackageName, prefix, suffix)
	}
	
	private def Configuration readConfigurationModel(File modelFile) {
		val jaxbContext = JAXBContext.newInstance(Configuration)
		val unmarshaller = jaxbContext.createUnmarshaller
		return unmarshaller.unmarshal(modelFile) as Configuration
	}
	
	private def generateVariantClass(Parameters parameters) {
		val extension nameProvider = new NameProvider
		val extension featureNameConverter = new FeatureNameConverter
		val rootName = parameters.configurationModel.root.name
		val simpleName = parameters.className
		
		val selectedFeatures = parameters.configurationModel
										 .feature
										 .map[name]
		                                 .map[convertToValidSimpleFeatureName(it, parameters.prefix, parameters.suffix)]
		                                 .map[getSimpleFeaturesEnumName(rootName) + '.' + it]
		
		val outputFile = prepareOutputFile(parameters)
		Files.write(outputFile.toPath, '''
			package «parameters.packageName»;
			
			«IF parameters.packageName != parameters.featuresPackageName»
				import «parameters.featuresPackageName».«getSimpleVariantInterfaceName(rootName)»;
				import «parameters.featuresPackageName».«getSimpleSelectedFeaturesAnnotationName(rootName)»;
				import «parameters.featuresPackageName».«getSimpleFeaturesEnumName(rootName)»;
				
			«ENDIF»
			@«getSimpleSelectedFeaturesAnnotationName(rootName)»( {«selectedFeatures.join(', ')»} )
			public final class «simpleName» implements «getSimpleVariantInterfaceName(rootName)» {
				
			}
		'''.toString.getBytes(StandardCharsets.UTF_8))
	}
	
	
	private def getRoot(Configuration configurationModel) {
		val features = configurationModel.feature
		features.head
	}
	
	private def File prepareOutputFile(Parameters parameters) {
		val packagePath = parameters.packageName.replace('.', '/')
		val outputFileParent = new File(parameters.outputFolder, packagePath)
		outputFileParent.mkdirs
	
		new File(outputFileParent, '''«parameters.className».java''')
	}
	
	@Accessors
	private static final class Parameters {
		
		val Configuration configurationModel
		val String packageName
		val String className
		val File outputFolder
		val String featuresPackageName
		val String prefix
		val String suffix
		
	}
	
}