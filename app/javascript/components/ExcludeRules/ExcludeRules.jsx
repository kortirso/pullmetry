import React, { useState, useEffect } from 'react';

import { Chevron } from '../../svg';
import { Select } from './Select';

const ruleKeys = {
  title: 'Title',
  description: 'Description',
  branch_name: 'PRs branch',
  destination_branch_name: 'Target branch'
};

export const ExcludeRules = ({ initialRules }) => {
  const [pageState, setPageState] = useState({
    expanded: false,
    rules: [],
    rulesValue: ''
  });

  useEffect(() => {
    const rules = Object.entries(initialRules).map(([key, values]) => {
      return values.map((element) => { return { id: Math.floor(Math.random() * 1000), key: key, value: element } });
    }).flat();

    setPageState({ ...pageState, rules: rules });
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const toggle = () => setPageState({ ...pageState, expanded: !pageState.expanded });

  const addExcludeRule = () => {
    const rules = pageState.rules.concat({ id: Math.floor(Math.random() * 1000), key: 'title', value: '' });
    updateRulesValue(rules);
  };

  const updateExcludeRuleKey = (rule, key) => {
    const rules = pageState.rules.map((element) => {
      if (element.id !== rule.id) return element;

      element.key = key;
      return element;
    });
    updateRulesValue(rules);
  };

  const updateExcludeRuleValue = (rule, value) => {
    const rules = pageState.rules.map((element) => {
      if (element.id !== rule.id) return element;

      element.value = value;
      return element;
    });
    updateRulesValue(rules);
  }

  const removeExcludeRule = (rule) => {
    const rules = pageState.rules.filter((element) => element.id !== rule.id);
    updateRulesValue(rules);
  }

  const updateRulesValue = (rules) => {
    const result = rules.reduce((acc, rule) => {
      if (acc[rule.key]) acc[rule.key].concat(rule.value);
      else acc[rule.key] = [rule.value];

      return acc;
    }, {});

    setPageState({ ...pageState, rules: rules, rulesValue: JSON.stringify(result) });
  };

  const renderExcludeRules = () => {
    return pageState.rules.map((rule) => {
      return (
        <div className="flex mb-4" key={rule.id}>
          <div className="form-field flex-1 mr-4 mb-0">
            <Select
              items={ruleKeys}
              onSelect={(value) => updateExcludeRuleKey(rule, value)}
              selectedValue={rule.key}
            />
          </div>
          <div className="form-field flex-1 mr-4 mb-0">
            <input
              className="form-value w-full text-sm"
              defaultValue={rule.value}
              onChange={(event) => updateExcludeRuleValue(rule, event.target.value)}
            />
          </div>
          <div className="flex items-center">
            <span
              className="bg-red-500 rounded-full py-1 px-2 text-sm text-black"
              onClick={() => removeExcludeRule(rule)}
            >X</span>
          </div>
        </div>
      );
    });
  };

  return (
    <div className="bg-white border-b border-gray-200">
      <div
        className="cursor-pointer py-6 px-8 flex justify-between items-center"
        onClick={() => toggle()}
      >
        <h2 className="m-0 text-xl">Pull requests</h2>
        <Chevron rotated={pageState.expanded} />
      </div>
      {pageState.expanded ? (
        <div class="py-6 px-8">
          <div class="grid lg:grid-cols-2 gap-8">
            <div>
              <input
                name="jsonb_columns_configuration[pull_request_exclude_rules]"
                type="hidden"
                value={pageState.rulesValue}
              />
              {renderExcludeRules()}
              <span
                className="btn-primary btn-small"
                onClick={addExcludeRule}
              >Add exclude rule</span>
            </div>
            <div>
              <p>You can select rules for excluding pull requests from statistics calculations, usually it can be releases, hotfixes to master branch or synchronize pull requests from master branch.</p>
              <p className="mt-2">Pull request will be excluded if at least 1 rule is matched.</p>
            </div>
          </div>
        </div>
      ) : null}
    </div>
  );
};
