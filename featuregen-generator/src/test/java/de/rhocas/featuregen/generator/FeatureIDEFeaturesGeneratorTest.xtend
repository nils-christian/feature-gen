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
 * A simple unit test for {@link FeatureIDEFeaturesGenerator}.
 *
 * @author Nils Christian Ehmke
 */
final class FeatureIDEFeaturesGeneratorTest {

	@Rule
	public val TemporaryFolder temporaryFolder = new TemporaryFolder
	
	@Rule
	public val ExpectedException expectedException = ExpectedException.none
	
	@Test
	def void simpleCaseShouldBeGeneratedCorrectly() {
		val modelFilePath = class.getResource('/model.xml').path
		val outputFolderPath = temporaryFolder.root.absolutePath
		
		val generator = new FeatureIDEFeaturesGenerator()
		generator.generate(#[modelFilePath, outputFolderPath, 'test'])
		val generatedFiles = collectGeneratedFiles()
		
		assertEquals('''
			package test;
			
			import de.rhocas.featuregen.lib.FeatureGenLabel;
			
			/**
			 * This enumeration contains all available features.<br>
			 * <br>
			 * This enumeration is generated.
			 */
			public enum RootFeature {
				
				@FeatureGenLabel( "Root" )
				ROOT_FEATURE,
				/**
				 * This is Feature 1.
				 */
				@FeatureGenLabel( "F1" )
				F1_FEATURE
			}'''.toString, generatedFiles.get('RootFeature.java'))
			
		assertEquals('''
			package test;
			
			import java.util.Set;
			import java.util.EnumSet;
			import java.util.Objects;
			import java.util.List;
			import java.util.Arrays;
			import java.util.Collections;
			
			/**
			 * This service allows to check which features are currently active.<br>
			 * <br>
			 * Note that instances of this class are immutable and thus inherent thread safe.<br>
			 * <br>
			 * This service is generated.
			 */
			public final class RootFeatureCheckService {
				
				private final Set<RootFeature> activeFeatures;
				private final String description;
				
				private RootFeatureCheckService( final List<RootFeature> selectedFeatures, final String variantName ) {
					activeFeatures = EnumSet.noneOf( RootFeature.class );
					activeFeatures.addAll( selectedFeatures );
					
					description = "RootFeatureCheckService [" + variantName + "]";
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
				public boolean isFeatureActive( final RootFeature feature ) {
					Objects.requireNonNull( feature, "The feature must not be null." );
					
					return activeFeatures.contains( feature );
				}
				
				@Override
				public String toString( ) {
					return description;
				}
				
				/**
				 * Creates a new instance of this service with the features of the given variant.
				 *
				 * @param variant
				 *		The new variant. Must not be {@code null} and must be annotated with {@link RootSelectedFeatures}.
				 *
				 * @return A new feature check service.
				 * 
				 * @throws NullPointerException
				 *		If the given variant is {@code null} or not annotated with {@link RootSelectedFeatures}.
				 */
				public static RootFeatureCheckService of( final Class<? extends RootVariant> variant ) {
					Objects.requireNonNull( variant, "The variant must not be null." );
					
					final RootSelectedFeatures selectedFeaturesAnnotation = variant.getAnnotation( RootSelectedFeatures.class );
					Objects.requireNonNull( selectedFeaturesAnnotation, "The variant must be annotated with RootSelectedFeatures." );
					final List<RootFeature> selectedFeatures = Arrays.asList( selectedFeaturesAnnotation.value( ) );
				
					return new RootFeatureCheckService( selectedFeatures, variant.getSimpleName( ) );
				}
				
				/**
				 * Creates a new instance of this service without any active features.
				 *
				 * @return A new feature check service.
				 */	
				public static RootFeatureCheckService empty( ) {
					return new RootFeatureCheckService( Collections.emptyList( ), "Empty" );
				}
				
			}'''.toString, generatedFiles.get('RootFeatureCheckService.java'))
		
		assertEquals('''
			package test;
			
			import java.lang.annotation.Retention;
			import java.lang.annotation.RetentionPolicy;
			import java.lang.annotation.Target;
			import java.lang.annotation.ElementType;
			import de.rhocas.featuregen.lib.FeatureGenSelectedFeatures;
			
			/**
			 * This annotation is used to mark which features the annotated variant provides.<br>
			 * <br>
			 * This annotation is generated.
			 */
			@Retention( RetentionPolicy.RUNTIME )
			@Target( ElementType.TYPE )
			@FeatureGenSelectedFeatures( )
			public @interface RootSelectedFeatures {
				
				/**
				 * The selected features.
				 */
				RootFeature[] value( );
				
			}'''.toString, generatedFiles.get('RootSelectedFeatures.java'))
		
		assertEquals('''
			package test;
			
			/**
			 * This is a marker interface for all variants.<br>
			 * <br>
			 * This interface is generated.
			 */
			public interface RootVariant {
				
			}'''.toString, generatedFiles.get('RootVariant.java'))
	}
	
	@Test
	def void extendedModelShouldBeGeneratedCorrectly() {
		val modelFilePath = class.getResource('/extendedModel.xml').path
		val outputFolderPath = temporaryFolder.root.absolutePath
		
		val generator = new FeatureIDEFeaturesGenerator()
		generator.generate(#[modelFilePath, outputFolderPath, 'test'])
		val generatedFiles = collectGeneratedFiles()
		
		assertEquals('''
			package test;
			
			import de.rhocas.featuregen.lib.FeatureGenLabel;
			
			/**
			 * This enumeration contains all available features.<br>
			 * <br>
			 * This enumeration is generated.
			 */
			public enum RootFeature {
				
				@FeatureGenLabel( "F1" )
				F1_FEATURE,
				@FeatureGenLabel( "F2" )
				F2_FEATURE,
				@FeatureGenLabel( "F2.1" )
				F21_FEATURE,
				@FeatureGenLabel( "F2.2" )
				F22_FEATURE,
				@FeatureGenLabel( "F3" )
				F3_FEATURE,
				@FeatureGenLabel( "F3.1" )
				F31_FEATURE,
				@FeatureGenLabel( "F3.2" )
				F32_FEATURE,
				@FeatureGenLabel( "F4" )
				F4_FEATURE,
				@FeatureGenLabel( "F4.1" )
				F41_FEATURE,
				@FeatureGenLabel( "F4.2" )
				F42_FEATURE,
				@FeatureGenLabel( "F5" )
				F5_FEATURE,
				@FeatureGenLabel( "F5.1" )
				F51_FEATURE,
				@FeatureGenLabel( "F5.2" )
				F52_FEATURE
			}'''.toString, generatedFiles.get('RootFeature.java'))
			
		assertEquals('''
			package test;
			
			import java.util.Set;
			import java.util.EnumSet;
			import java.util.Objects;
			import java.util.List;
			import java.util.Arrays;
			import java.util.Collections;
			
			/**
			 * This service allows to check which features are currently active.<br>
			 * <br>
			 * Note that instances of this class are immutable and thus inherent thread safe.<br>
			 * <br>
			 * This service is generated.
			 */
			public final class RootFeatureCheckService {
				
				private final Set<RootFeature> activeFeatures;
				private final String description;
				
				private RootFeatureCheckService( final List<RootFeature> selectedFeatures, final String variantName ) {
					activeFeatures = EnumSet.noneOf( RootFeature.class );
					activeFeatures.addAll( selectedFeatures );
					
					description = "RootFeatureCheckService [" + variantName + "]";
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
				public boolean isFeatureActive( final RootFeature feature ) {
					Objects.requireNonNull( feature, "The feature must not be null." );
					
					return activeFeatures.contains( feature );
				}
				
				@Override
				public String toString( ) {
					return description;
				}
				
				/**
				 * Creates a new instance of this service with the features of the given variant.
				 *
				 * @param variant
				 *		The new variant. Must not be {@code null} and must be annotated with {@link RootSelectedFeatures}.
				 *
				 * @return A new feature check service.
				 * 
				 * @throws NullPointerException
				 *		If the given variant is {@code null} or not annotated with {@link RootSelectedFeatures}.
				 */
				public static RootFeatureCheckService of( final Class<? extends RootVariant> variant ) {
					Objects.requireNonNull( variant, "The variant must not be null." );
					
					final RootSelectedFeatures selectedFeaturesAnnotation = variant.getAnnotation( RootSelectedFeatures.class );
					Objects.requireNonNull( selectedFeaturesAnnotation, "The variant must be annotated with RootSelectedFeatures." );
					final List<RootFeature> selectedFeatures = Arrays.asList( selectedFeaturesAnnotation.value( ) );
				
					return new RootFeatureCheckService( selectedFeatures, variant.getSimpleName( ) );
				}
				
				/**
				 * Creates a new instance of this service without any active features.
				 *
				 * @return A new feature check service.
				 */	
				public static RootFeatureCheckService empty( ) {
					return new RootFeatureCheckService( Collections.emptyList( ), "Empty" );
				}
				
			}'''.toString, generatedFiles.get('RootFeatureCheckService.java'))
		
		assertEquals('''
			package test;
			
			import java.lang.annotation.Retention;
			import java.lang.annotation.RetentionPolicy;
			import java.lang.annotation.Target;
			import java.lang.annotation.ElementType;
			import de.rhocas.featuregen.lib.FeatureGenSelectedFeatures;
			
			/**
			 * This annotation is used to mark which features the annotated variant provides.<br>
			 * <br>
			 * This annotation is generated.
			 */
			@Retention( RetentionPolicy.RUNTIME )
			@Target( ElementType.TYPE )
			@FeatureGenSelectedFeatures( )
			public @interface RootSelectedFeatures {
				
				/**
				 * The selected features.
				 */
				RootFeature[] value( );
				
			}'''.toString, generatedFiles.get('RootSelectedFeatures.java'))
		
		assertEquals('''
			package test;
			
			/**
			 * This is a marker interface for all variants.<br>
			 * <br>
			 * This interface is generated.
			 */
			public interface RootVariant {
				
			}'''.toString, generatedFiles.get('RootVariant.java'))
	}
	
	@Test
	def void simpleCaseWithPrefixAndSuffixShouldBeGeneratedCorrectly() {
		val modelFilePath = class.getResource('/model.xml').path
		val outputFolderPath = temporaryFolder.root.absolutePath
		
		val generator = new FeatureIDEFeaturesGenerator()
		generator.generate(#[modelFilePath, outputFolderPath, 'test', 'prefix_', '_suffix'])
		val generatedFiles = collectGeneratedFiles()
		
		assertEquals('''
			package test;
			
			import de.rhocas.featuregen.lib.FeatureGenLabel;
			
			/**
			 * This enumeration contains all available features.<br>
			 * <br>
			 * This enumeration is generated.
			 */
			public enum RootFeature {
				
				@FeatureGenLabel( "Root" )
				PREFIX_ROOT_SUFFIX,
				/**
				 * This is Feature 1.
				 */
				@FeatureGenLabel( "F1" )
				PREFIX_F1_SUFFIX
			}'''.toString, generatedFiles.get('RootFeature.java'))
			
		assertEquals('''
			package test;
			
			import java.util.Set;
			import java.util.EnumSet;
			import java.util.Objects;
			import java.util.List;
			import java.util.Arrays;
			import java.util.Collections;
			
			/**
			 * This service allows to check which features are currently active.<br>
			 * <br>
			 * Note that instances of this class are immutable and thus inherent thread safe.<br>
			 * <br>
			 * This service is generated.
			 */
			public final class RootFeatureCheckService {
				
				private final Set<RootFeature> activeFeatures;
				private final String description;
				
				private RootFeatureCheckService( final List<RootFeature> selectedFeatures, final String variantName ) {
					activeFeatures = EnumSet.noneOf( RootFeature.class );
					activeFeatures.addAll( selectedFeatures );
					
					description = "RootFeatureCheckService [" + variantName + "]";
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
				public boolean isFeatureActive( final RootFeature feature ) {
					Objects.requireNonNull( feature, "The feature must not be null." );
					
					return activeFeatures.contains( feature );
				}
				
				@Override
				public String toString( ) {
					return description;
				}
				
				/**
				 * Creates a new instance of this service with the features of the given variant.
				 *
				 * @param variant
				 *		The new variant. Must not be {@code null} and must be annotated with {@link RootSelectedFeatures}.
				 *
				 * @return A new feature check service.
				 * 
				 * @throws NullPointerException
				 *		If the given variant is {@code null} or not annotated with {@link RootSelectedFeatures}.
				 */
				public static RootFeatureCheckService of( final Class<? extends RootVariant> variant ) {
					Objects.requireNonNull( variant, "The variant must not be null." );
					
					final RootSelectedFeatures selectedFeaturesAnnotation = variant.getAnnotation( RootSelectedFeatures.class );
					Objects.requireNonNull( selectedFeaturesAnnotation, "The variant must be annotated with RootSelectedFeatures." );
					final List<RootFeature> selectedFeatures = Arrays.asList( selectedFeaturesAnnotation.value( ) );
				
					return new RootFeatureCheckService( selectedFeatures, variant.getSimpleName( ) );
				}
				
				/**
				 * Creates a new instance of this service without any active features.
				 *
				 * @return A new feature check service.
				 */	
				public static RootFeatureCheckService empty( ) {
					return new RootFeatureCheckService( Collections.emptyList( ), "Empty" );
				}
				
			}'''.toString, generatedFiles.get('RootFeatureCheckService.java'))
		
		assertEquals('''
			package test;
			
			import java.lang.annotation.Retention;
			import java.lang.annotation.RetentionPolicy;
			import java.lang.annotation.Target;
			import java.lang.annotation.ElementType;
			import de.rhocas.featuregen.lib.FeatureGenSelectedFeatures;
			
			/**
			 * This annotation is used to mark which features the annotated variant provides.<br>
			 * <br>
			 * This annotation is generated.
			 */
			@Retention( RetentionPolicy.RUNTIME )
			@Target( ElementType.TYPE )
			@FeatureGenSelectedFeatures( )
			public @interface RootSelectedFeatures {
				
				/**
				 * The selected features.
				 */
				RootFeature[] value( );
				
			}'''.toString, generatedFiles.get('RootSelectedFeatures.java'))
		
		assertEquals('''
			package test;
			
			/**
			 * This is a marker interface for all variants.<br>
			 * <br>
			 * This interface is generated.
			 */
			public interface RootVariant {
				
			}'''.toString, generatedFiles.get('RootVariant.java'))
	}
	
	@Test
	def void missingFileShouldResultInError() {
		val outputFolderPath = temporaryFolder.root.absolutePath
		
		val generator = new FeatureIDEFeaturesGenerator()
		
		expectedException.expect(IllegalArgumentException)
		expectedException.expectMessage('Model file "non/existing/file" can not be found.')
		generator.generate(#['non/existing/file', outputFolderPath, 'test'])
	}
	
	@Test
	def void missingArgumentsShouldResultInError() {
		val generator = new FeatureIDEFeaturesGenerator()
		
		expectedException.expect(IllegalArgumentException)
		expectedException.expectMessage('Invalid number of arguments. Expected at least 3, but was 1.')
		generator.generate(#['file'])
	}
	 
	private def Map<String, String> collectGeneratedFiles() {
		val generatorTestHelper = new GeneratorTestHelper()
		generatorTestHelper.collectGeneratedFiles(temporaryFolder.root)
	}
	
}