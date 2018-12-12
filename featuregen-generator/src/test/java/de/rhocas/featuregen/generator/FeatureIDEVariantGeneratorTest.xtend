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

import java.util.Map
import org.junit.Rule
import org.junit.Test
import org.junit.rules.ExpectedException
import org.junit.rules.TemporaryFolder

import static org.junit.Assert.assertEquals

/**
 * A simple unit test for {@link FeatureIDEVariantGenerator}.
 *
 * @author Nils Christian Ehmke
 */
final class FeatureIDEVariantGeneratorTest {
	
	@Rule
	public val TemporaryFolder temporaryFolder = new TemporaryFolder
	
	@Rule
	public val ExpectedException expectedException = ExpectedException.none
	
	@Test
	def void simpleCaseShouldBeGeneratedCorrectly() {
		val featureModelFilePath = class.getResource('/model.xml').path
		val outputFolderPath = temporaryFolder.root.absolutePath
		
		val featureGenerator = new FeatureIDEFeaturesGenerator()
		featureGenerator.generate(#[featureModelFilePath, outputFolderPath, 'test'])
		
		val configurationModelFilePath = class.getResource('/configuration.xml').path
		val variantGenerator = new FeatureIDEVariantGenerator()
		variantGenerator.generate(#[configurationModelFilePath, featureModelFilePath, outputFolderPath, 'test', 'Variant', 'test'])

		val generatedFiles = collectGeneratedFiles()

		assertEquals('''
				package test;
				
				@RootSelectedFeatures( {RootFeature.ROOT_FEATURE, RootFeature.F1_FEATURE} )
				public final class Variant implements RootVariant {
					
					private Variant( ) {
					}
					
				}'''.toString, generatedFiles.get('Variant.java'))
			
	}
	
	@Test
	def void simpleCaseInDifferentPackagesShouldBeGeneratedCorrectly() {
		val featureModelFilePath = class.getResource('/model.xml').path
		val outputFolderPath = temporaryFolder.root.absolutePath
		
		val featureGenerator = new FeatureIDEFeaturesGenerator()
		featureGenerator.generate(#[featureModelFilePath, outputFolderPath, 'test1'])
		
		val configurationModelFilePath = class.getResource('/configuration.xml').path
		val variantGenerator = new FeatureIDEVariantGenerator()
		variantGenerator.generate(#[configurationModelFilePath, featureModelFilePath, outputFolderPath, 'test2', 'Variant', 'test1'])

		val generatedFiles = collectGeneratedFiles()

		assertEquals('''
				package test2;
				
				import test1.RootVariant;
				import test1.RootSelectedFeatures;
				import test1.RootFeature;
				
				@RootSelectedFeatures( {RootFeature.ROOT_FEATURE, RootFeature.F1_FEATURE} )
				public final class Variant implements RootVariant {
					
					private Variant( ) {
					}
					
				}'''.toString, generatedFiles.get('Variant.java'))
			
	}
	
	@Test
	def void simpleCaseWithPrefixAndSuffixShouldBeGeneratedCorrectly() {
		val featureModelFilePath = class.getResource('/extendedModel.xml').path
		val outputFolderPath = temporaryFolder.root.absolutePath
		
		val featureGenerator = new FeatureIDEFeaturesGenerator()
		featureGenerator.generate(#[featureModelFilePath, outputFolderPath, 'test', 'prefix_', '_suffix'])
		
		val configurationModelFilePath = class.getResource('/extendedConfiguration.xml').path
		val variantGenerator = new FeatureIDEVariantGenerator()
		variantGenerator.generate(#[configurationModelFilePath, featureModelFilePath, outputFolderPath, 'test', 'Variant', 'test', 'prefix_', '_suffix'])

		val generatedFiles = collectGeneratedFiles()

		assertEquals('''
				package test;
				
				@RootSelectedFeatures( {RootFeature.PREFIX_F1_SUFFIX} )
				public final class Variant implements RootVariant {
					
					private Variant( ) {
					}
					
				}'''.toString, generatedFiles.get('Variant.java'))
			
	}
	
	@Test
	def void missingFileShouldResultInError() {
		val outputFolderPath = temporaryFolder.root.absolutePath
		
		val generator = new FeatureIDEVariantGenerator()
		
		expectedException.expect(IllegalArgumentException)
		expectedException.expectMessage('Model file "non/existing/file" can not be found.')
		generator.generate(#['non/existing/file', '', outputFolderPath, 'test', 'Variant', 'test'])
	}
	
	private def Map<String, String> collectGeneratedFiles() {
		val generatorTestHelper = new GeneratorTestHelper()
		generatorTestHelper.collectGeneratedFiles(temporaryFolder.root)
	}
	
}