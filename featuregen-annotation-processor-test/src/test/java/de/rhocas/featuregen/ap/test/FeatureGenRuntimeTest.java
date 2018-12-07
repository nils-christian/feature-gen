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

package de.rhocas.featuregen.ap.test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.ExpectedException;

import de.rhocas.featuregen.ap.test.feature.FeatureGenTestFeature;
import de.rhocas.featuregen.ap.test.feature.FeatureGenTestFeatureCheckService;
import de.rhocas.featuregen.ap.test.variant.Variant1;
import de.rhocas.featuregen.ap.test.variant.Variant2;

/**
 * A simple unit test that makes sure that the runtime behavior of the feature-gen API works as intended.
 *
 * @author Nils Christian Ehmke
 */
public final class FeatureGenRuntimeTest {

	@Rule
	public ExpectedException expectedException = ExpectedException.none();
	
	@Test
	public void featureCheckWithoutVariant() {
		final FeatureGenTestFeatureCheckService featureCheckService = FeatureGenTestFeatureCheckService.empty();
		for (final FeatureGenTestFeature feature : FeatureGenTestFeature.values()) {
			final boolean featureActive = featureCheckService.isFeatureActive(feature);
			assertFalse(featureActive);
		}
	}

	@Test
	public void featureCheckWithVariant() {
		final FeatureGenTestFeatureCheckService featureCheckService = FeatureGenTestFeatureCheckService.of(Variant1.class);

		assertTrue(featureCheckService.isFeatureActive(FeatureGenTestFeature.FEATUREGENTEST_FEATURE));
		assertTrue(featureCheckService.isFeatureActive(FeatureGenTestFeature.F2_FEATURE));
		
		assertFalse(featureCheckService.isFeatureActive(FeatureGenTestFeature.F51_FEATURE));
	}
	
	@Test
	public void featureCheckWithTwoVariants() {
		final FeatureGenTestFeatureCheckService featureCheckServiceVariant1 = FeatureGenTestFeatureCheckService.of(Variant1.class);
		final FeatureGenTestFeatureCheckService featureCheckServiceVariant2 = FeatureGenTestFeatureCheckService.of(Variant2.class);
		
		assertFalse(featureCheckServiceVariant1.isFeatureActive(FeatureGenTestFeature.F51_FEATURE));
		assertTrue(featureCheckServiceVariant2.isFeatureActive(FeatureGenTestFeature.F51_FEATURE));
	}
	
	@Test
	public void featureCheckWithNullVariant() {
		expectedException.expect(NullPointerException.class);
		expectedException.expectMessage("The variant must not be null.");
		FeatureGenTestFeatureCheckService.of(null);
	}
	
	@Test
	public void featureCheckWithNullFeature() {
		final FeatureGenTestFeatureCheckService featureCheckService = FeatureGenTestFeatureCheckService.of(Variant1.class);
		
		expectedException.expect(NullPointerException.class);
		expectedException.expectMessage("The feature must not be null.");
		featureCheckService.isFeatureActive(null);
	}

}
