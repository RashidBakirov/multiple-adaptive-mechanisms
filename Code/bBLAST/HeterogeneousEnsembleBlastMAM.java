/*
 *    HeterogeneousEnsembleBlast.java
 *    Copyright (C) 2017 University of Waikato, Hamilton, New Zealand
 *    @author Jan N. van Rijn (j.n.van.rijn@liacs.leidenuniv.nl)
 *
 *    This program is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program. If not, see <http://www.gnu.org/licenses/>.
 *    
 */
package moa.classifiers.meta;

import com.github.javacliparser.IntOption;
import com.yahoo.labs.samoa.instances.Instance;
import moa.classifiers.MultiClassClassifier;
import moa.classifiers.meta.HeterogeneousEnsembleAbstract;


/**
 * BLAST (Best Last) for Heterogeneous Ensembles implemented with Fading Factors
 *
 * <p>
 * Given a set of (heterogeneous) classifiers, BLAST builds an ensemble, and
 * determines the weights of all ensemble members based on their performance on
 * recent observed instances. This implementation uses a window of recent 
 * instances, the size is determined by the 'w' parameter. 
 * </p>
 *
 * <p>
 * J. N. van Rijn, G. Holmes, B. Pfahringer, J. Vanschoren. Having a Blast:
 * Meta-Learning and Heterogeneous Ensembles for Data Streams. In 2015 IEEE
 * International Conference on Data Mining, pages 1003-1008. IEEE, 2015.
 * </p>
 *
 * <p>
 * Parameters:
 * </p>
 * <ul>
 * <li>-w : Window size</li>
 * <li>-b : Comma-separated string of classifiers</li>
 * <li>-g : Grace period (1 = optimal)</li>
 * <li>-k : Number of active classifiers</li>
 * </ul>
 *
 * @author Jan N. van Rijn (j.n.van.rijn@liacs.leidenuniv.nl)
 * @version $Revision: 1 $
 */
public class HeterogeneousEnsembleBlastMAM extends HeterogeneousEnsembleAbstract implements MultiClassClassifier {

	private static final long serialVersionUID = 1L;

	protected boolean[][] onlineHistory;

	public IntOption windowSizeOption = new IntOption("windowSize", 'w',
			"The window size over which Online Performance Estimation is done.", 1000,
			1, Integer.MAX_VALUE);
			
	public int strategyOption;

	@Override
	public void resetLearningImpl() {
		this.historyTotal = new double[this.ensemble.length];
		this.onlineHistory = new boolean[this.ensemble.length][windowSizeOption
				.getValue()];
		this.instancesSeen = 0;

		for (int i = 0; i < this.ensemble.length; i++) {
			this.ensemble[i].resetLearning();
		}
	}

	@Override
	public void trainOnInstanceImpl(Instance inst) {
		int wValue = windowSizeOption.getValue();

		for (int i = 0; i < this.ensemble.length; i++) {

			if (strategyOption==2 || strategyOption==0) {
				// Online Performance estimation
				double[] votes = ensemble[i].getVotesForInstance(inst);
				boolean correct = (maxIndex(votes) * 1.0 == inst.classValue());

				if (correct && !onlineHistory[i][instancesSeen % wValue]) {
					// performance estimation increases
					onlineHistory[i][instancesSeen % wValue] = true;
					historyTotal[i] += 1.0 / wValue;
				} else if (!correct && onlineHistory[i][instancesSeen % wValue]) {
					// performance estimation decreases
					onlineHistory[i][instancesSeen % wValue] = false;
					historyTotal[i] -= 1.0 / wValue;
				} else {
					// nothing happens
				}
			}
			
			if (strategyOption==1 || strategyOption==0) {
				this.ensemble[i].trainOnInstance(inst);
			}
		}

		instancesSeen += 1;
		if (instancesSeen % gracePerionOption.getValue() == 0) {
			topK = topK(historyTotal, activeClassifiersOption.getValue());
		}
	}
}
