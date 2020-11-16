# %reset -f
import sys
import copy
import numpy as np
import pandas as pd
#from skmultiflow.meta import LeverageBagging
from leverage_bagging_batch import LeverageBagging
from skmultiflow.trees import HoeffdingTree
from skmultiflow.bayes import NaiveBayes
from skmultiflow.lazy.knn import KNN


# Setting up the LeverageBagging classifier to work with KNN classifiers
# LB_MODE=0 ==> #not doing anything
# LB_MODE=1 ==> #updating the models
# LB_MODE=2 ==> #adding a new model
# LB_MODE=3 ==> #updating models AND adding a new model

def lev_bag(csv_trn, csv_tst, base_estimator, batchsize, strategy, r):

    ######################
    # dataTrn='26_trn.csv'
    # dataTst='26_tst.csv'
    # batchSize=10
    # baseEstimator=0
    ######################
    # print(dataTrn)
    # print(dataTst)
    # print(baseEstimator)
    # print(batchSize)

    NUMFOLDS = 10

    batchsize = int(batchsize)
    baseEstimator = int(base_estimator)
    strategy=int(strategy)
    r=int(r)

    if r==0:
        flag_rc=False
    else:
        flag_rc=True

    batch_no = 1
    d_trn = pd.read_csv('~/data/'+csv_trn, header=None)
    x_trn = d_trn.iloc[:, :-1].values
    y_trn = d_trn.iloc[:, -1].values


    unique_targets = np.unique(y_trn).tolist()
    number_of_batches = int(np.floor(d_trn.shape[0] / batchsize))
    batch_trn_x = x_trn[(batch_no - 1) * batchsize:batch_no * batchsize, :]
    batch_trn_y = y_trn[(batch_no - 1) * batchsize:batch_no * batchsize]
    pred_trn = np.zeros((d_trn.shape[0]))
    res_trn = np.zeros((d_trn.shape[0]))
    xval_selection_idx = 0
    ams = np.zeros((number_of_batches, 2))
    acc_tst = None
    try:
        d_tst = pd.read_csv('~/data/'+csv_tst, header=None)
        x_tst = d_tst.iloc[:, :-1].values
        y_tst = d_tst.iloc[:, -1].values
        batch_size_tst = int(np.floor(d_tst.shape[0] / d_trn.shape[0]) * batchsize)
        batch_tst_x = x_tst[(batch_no - 1) * batch_size_tst:batch_no * batch_size_tst, :]
        batch_tst_y = y_tst[(batch_no - 1) * batch_size_tst:batch_no * batch_size_tst]
        pred_tst = np.zeros((d_tst.shape[0]))
        res_tst = np.zeros((d_tst.shape[0]))
    except:
        csv_tst = None

    if (baseEstimator == 0):
        model0 = LeverageBagging(base_estimator=NaiveBayes(), LB_MODE=1)
        #model0 = LeverageBagging(base_estimator=NaiveBayes())
    elif (baseEstimator == 1):
        model0 = LeverageBagging(base_estimator=HoeffdingTree(), LB_MODE=1)
        #model0 = LeverageBagging(base_estimator=HoeffdingTree())
    elif (baseEstimator == 2):
        #model0 = LeverageBagging(base_estimator=KNN(), n_estimators=100)
        model0 = LeverageBagging(base_estimator=KNN(), n_estimators=100, LB_MODE=1)

    if flag_rc:

        ensemble = [None] * 5

        for i in range(0, 5):
            ensemble[i] = model0.partial_fit(batch_trn_x, batch_trn_y, classes=unique_targets, LB_MODE=1)
        if csv_tst is not None:
            pred_tst_0 = ensemble[0].predict(batch_tst_x)
            pred_tst[(batch_no - 1) * batch_size_tst:batch_no * batch_size_tst] = pred_tst_0

    else:
        selected_ensemble = model0.partial_fit(batch_trn_x, batch_trn_y, classes=unique_targets, LB_MODE=1)
        if csv_tst is not None:
            pred_tst_0=selected_ensemble.predict(batch_tst_x)
            pred_tst[(batch_no - 1) * batch_size_tst:batch_no * batch_size_tst] = pred_tst_0

    if csv_tst is not None:
        res_tst[(batch_no - 1) * batch_size_tst:batch_no * batch_size_tst] = pred_tst_0 == batch_tst_y
    # for batch_no in range(1, number_of_batches):
    #
    #     print(batch_no)
    #
    #     batch_trn_x = x_trn[batch_no * batchsize:(batch_no+1) * batchsize, :]
    #     batch_trn_y = y_trn[batch_no * batchsize:(batch_no+1) * batchsize]
    #     selected_ensemble.partial_fit(batch_trn_x, batch_trn_y)
    #
    #     pred_batch = selected_ensemble.predict(batch_trn_x)
    #     acc=np.sum(pred_batch == batch_trn_y)
    #     print(acc)

    for batch_no in range(1, number_of_batches):

        #print(batch_no)

        batch_trn_x = x_trn[(batch_no) * batchsize:(batch_no+1) * batchsize, :]
        batch_trn_y = y_trn[(batch_no) * batchsize:(batch_no+1) * batchsize]


        if flag_rc is True:
            if strategy < 5:  # single AM strategies
                r = strategy
            else:
                r = xval_selection_idx

            pred_batch = ensemble[r].predict(batch_trn_x)
            pred_trn[(batch_no) * batchsize:(batch_no + 1) * batchsize] = pred_batch

            accAMs=np.zeros(4)
            for i in range(0, 4):

                pred = ensemble[i].predict(batch_trn_x)
                accAMs[i] = np.sum(pred == batch_trn_y)

            #print(accAMs)
            idx_best_am = np.argmax(accAMs)
            # if idx_best_am!=0:
            #     print(accAMs)
            selected_ensemble = ensemble[idx_best_am]


            if csv_tst is not None:
                batch_tst_x = x_tst[(batch_no) * batch_size_tst:(batch_no+1) * batch_size_tst, :]
                batch_tst_y = y_tst[(batch_no) * batch_size_tst:(batch_no+1) * batch_size_tst]
                pred_tst_batch = ensemble[r].predict(batch_tst_x)
                pred_tst[(batch_no) * batch_size_tst:(batch_no+1) * batch_size_tst] = pred_tst_batch
                res_tst[(batch_no) * batch_size_tst:(batch_no+1) * batch_size_tst] = pred_tst_batch == batch_tst_y

            r_actual = r
            ams[batch_no - 1, 0] = r_actual
            ams[batch_no - 1, 1] = r

        else:

            if csv_tst is not None:
                batch_tst_x = x_tst[(batch_no) * batch_size_tst:(batch_no+1) * batch_size_tst, :]
                batch_tst_y = y_tst[(batch_no) * batch_size_tst:(batch_no+1) * batch_size_tst]
                pred_tst_batch = selected_ensemble.predict(batch_tst_x)
                pred_tst[(batch_no) * batch_size_tst:(batch_no+1) * batch_size_tst] = pred_tst_batch
                res_tst[(batch_no) * batch_size_tst:(batch_no+1) * batch_size_tst] = pred_tst_batch == batch_tst_y

            pred_batch = selected_ensemble.predict(batch_trn_x)
            pred_trn[(batch_no) * batchsize:(batch_no+1) * batchsize] = pred_batch

        res_trn[(batch_no) * batchsize:(batch_no+1) * batchsize] = pred_batch == batch_trn_y

        # adaptation - ----------------------------------------------------

        # xval selection
        if strategy == 5:
            if flag_rc:
                xval_selection_idx = xval_select(ensemble[r], batch_trn_x, batch_trn_y, batchsize, NUMFOLDS)
            else:
                xval_selection_idx = xval_select(selected_ensemble, batch_trn_x, batch_trn_y, batchsize, NUMFOLDS)

        # create all variations of adaptation if flag return is set
        if flag_rc:
            for i in range(0, 5):
                ensemble[i] = copy.deepcopy(selected_ensemble)
                ensemble[i] = ensemble[i].partial_fit(batch_trn_x, batch_trn_y, LB_MODE=i)
        else:
            if strategy<5:
                r=strategy
            else:
                r = xval_selection_idx

            ams[batch_no - 1, 0] = r
            ams[batch_no - 1, 1] = r

            selected_ensemble = selected_ensemble.partial_fit(batch_trn_x, batch_trn_y, LB_MODE=r)


    acc_trn = (np.sum(res_trn[batchsize:])) / ((batch_no-1) * batchsize)
    if csv_tst is not None:
        acc_tst = np.mean(res_tst)

    if acc_tst is None:
        #print(acc_trn)
        return acc_trn
    else:
        #print(acc_tst)
        return acc_tst

def xval_select(ensemble, data, labels, batchsize, NUMFOLDS):
    test_size = np.round(batchsize // NUMFOLDS)
    sum_accuracy = np.zeros(4)

    for i in range (0, NUMFOLDS):

        x_tst = data[i*test_size:(i+1)*test_size, :]
        y_tst = labels[i*test_size:(i+1)*test_size]

        x_trn = np.append(data[:i*test_size,:],data[(i+1)*test_size:,:], axis=0)
        y_trn = np.append(labels[:i*test_size],labels[(i+1)*test_size:])

        for j in range(0,4):
            ensemble_xv = copy.deepcopy(ensemble)
            ensemble_xv = ensemble_xv.partial_fit(x_trn, y_trn, LB_MODE=j)
            pred = ensemble_xv.predict(x_tst)
            sum_accuracy[j] = sum_accuracy[j] + np.sum(pred == y_tst)

    #print(sum_accuracy)
    return np.argmax(sum_accuracy)


if __name__ == '__main__':
    #if (len(sys.argv) == 5):
    print(lev_bag(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]))
    # acc_trn, acc_tst = lev_bag('30_trn.csv', None, 0, 50, 0, True)
    # print(acc_trn)
    # print(acc_tst)
# for k in range(2):
#     for j in range(2):
#         for i in range(6):
#             try:
#                 acc=lev_bag('1_trn.csv', '1_tst.csv', k, 50, i, j)
#                 print((str(k)+' '+ str(j)+' '+str(i)+': '+str(acc) ))
#             except:
#                 print((str(k) + ' ' + str(j) + ' ' + str(i) + ': ' + 'Error!'))
#lev_bag('1_trn.csv', '1_tst.csv', 0, 50, 0, 1)