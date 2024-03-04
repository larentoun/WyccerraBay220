import { useBackend, useSharedState, useLocalState } from '../backend';
import { LabeledList, Section, Stack, Input, Box, Button } from '../components';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';

type CodexEntry = {
  name: string;
  lore: string;
  mechanics: string;
  antag: string;
};

type CodexData = {
  codexEntries: CodexEntry[];
  isAntagonist: BooleanLike;
  selectedEntry: string;
};

const CodexListTab = (props, context) => {
  const { act, data } = useBackend<CodexData>(context);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const { isAntagonist } = data;

  const filteredCodexies = data.codexEntries
    .filter((codexEntry) =>
      codexEntry.name.toLowerCase().includes(searchText.toLowerCase())
    )
    .sort((a, b) => a.name.localeCompare(b.name));

  return (
    <Section fill vertical>
      <Stack fill vertical>
        <Stack.Item>
          <Input
            mt={0.75}
            width="100%"
            placeholder="Поиск..."
            value={searchText}
            onInput={(e, value) => setSearchText(value)}
          />
        </Stack.Item>
        <Stack.Item grow>
          <Section fill scrollable>
            {filteredCodexies.map((codexEntry) =>
              !codexEntry.lore &&
              !codexEntry.mechanics &&
              !isAntagonist ? null : (
                <Button
                  key={codexEntry.name}
                  onClick={() => act('newEntry', { newEntry: codexEntry.name })}
                >
                  {codexEntry.name}
                </Button>
              )
            )}
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const CodexEntryView = (props, context) => {
  const { act, data } = useBackend<CodexData>(context);
  const { selectedEntry, isAntagonist } = data;
  const selectedCodexEntry = data.codexEntries.find(
    (i) => i.name === selectedEntry
  );
  const { name, lore, mechanics, antag } = selectedCodexEntry;
  return (
    <Section title={name}>
      {lore ? <Section title="Описание">{lore}</Section> : null}
      {mechanics ? <Section title="OOC">{mechanics}</Section> : null}
      {antag && isAntagonist ? (
        <Section title="Антагонист">{antag}</Section>
      ) : null}
    </Section>
  );
};

export const Codex = (props, context) => {
  const { act, data } = useBackend<CodexData>(context);
  const [tab] = useLocalState(context, 'tab', '');
  const { selectedEntry } = data;
  return (
    <Window width={400} height={600} title="Кодекс2">
      <Window.Content>
        <Button onClick={() => act('newEntry')}>home</Button>
        {selectedEntry ? <CodexEntryView /> : <CodexListTab />}
      </Window.Content>
    </Window>
  );
};
